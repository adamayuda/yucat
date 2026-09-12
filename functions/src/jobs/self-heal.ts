/**
 * Nightly self-heal (scan-pipeline Phase 3).
 *
 * Two kinds of rows accumulate in the catalogue: analyses that found no
 * nutrition (score 0, cached and served as "hits" forever — 225 rows, 30% of
 * full analyses) and rows with data but no image. Healing them used to happen
 * inline, on a user's request, at most once per 14 days per row — which turned
 * a 4-second cache hit into a 30-second one and, in practice, fired once in
 * two weeks. This job does it off the request path, bounded per night.
 *
 * Pass 1 — re-analyse stale score-0 rows from their brand/name alone (the
 * analyze paths accept a null image). A recovered analysis overwrites the row
 * in place under the same objectID, keeping its image, gtin and translations
 * cleared (they described the empty analysis). A miss stamps
 * `lastAnalysisAttempt` so the row is not retried tomorrow.
 * Pass 2 — image backfill for rows with data and no image, via SerpAPI.
 * Both passes run on `litters` too, with smaller caps.
 *
 * `SELF_HEAL_DRY_RUN=true` logs the candidates and touches nothing — run that
 * first after a deploy.
 */
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import {config, selfHealDryRunParam} from "../config";
import {Product} from "../models/product";
import {Litter} from "../models/litter";
import {
  analyzeLitterImage,
  analyzeProductImageParallel,
  findProductImageUrl,
} from "../services/anthropic.service";
import {
  cacheLitter,
  cacheProduct,
  fetchRowsByFilter,
  partialUpdateRecord,
} from "../services/algolia.service";
import {processProductImage} from "../utils/image-helpers";
import {mapPool} from "../utils/map-pool";

type ProductRow = Pick<
  Product,
  "barcode" | "name" | "brand" | "foodType" | "imageUrl" | "score" | "gtin" |
  "lastAnalysisAttempt" | "lastImageAttempt" | "analysisSource"
> & {objectID: string};

type LitterRow = Pick<
  Litter,
  "id" | "name" | "brand" | "imageUrl" | "score" | "gtin" |
  "lastAnalysisAttempt" | "lastImageAttempt"
> & {objectID: string};

const ROW_ATTRIBUTES = [
  "objectID", "barcode", "id", "name", "brand", "foodType", "imageUrl", "score",
  "gtin", "lastAnalysisAttempt", "lastImageAttempt", "analysisSource",
];

const isStale = (ts?: number): boolean =>
  !ts || Date.now() - ts > config.selfHeal.reanalyzeAfterMs;

interface Summary {
  dryRun: boolean;
  reanalyzeCandidates: number;
  reanalyzed: number;
  recovered: number;
  imageCandidates: number;
  imagesAttempted: number;
  imagesFound: number;
  litterReanalyzeCandidates: number;
  litterReanalyzed: number;
  litterRecovered: number;
  litterImageCandidates: number;
  litterImagesFound: number;
  budgetExhausted: boolean;
  ms: number;
}

export const nightlySelfHeal = onSchedule(
  {
    schedule: config.selfHeal.schedule,
    timeZone: config.selfHeal.timeZone,
    timeoutSeconds: config.selfHeal.timeoutSeconds,
    memory: config.functions.memory,
    cpu: 1,
    retryCount: 0,
    secrets: ["ANTHROPIC_API_KEY", "ALGOLIA_API_KEY", "SERPAPI_API_KEY"],
  },
  async () => {
    const started = Date.now();
    const dryRun = selfHealDryRunParam.value();
    const runId = `heal-${Date.now()}`;
    const withinBudget = () => Date.now() - started < config.selfHeal.budgetMs;
    const summary: Summary = {
      dryRun,
      reanalyzeCandidates: 0, reanalyzed: 0, recovered: 0,
      imageCandidates: 0, imagesAttempted: 0, imagesFound: 0,
      litterReanalyzeCandidates: 0, litterReanalyzed: 0, litterRecovered: 0,
      litterImageCandidates: 0, litterImagesFound: 0,
      budgetExhausted: false, ms: 0,
    };
    const {indexName, litterIndexName} = config.algolia;

    // ---- Pass 1: re-analyse stale score-0 products --------------------------
    const noData = await fetchRowsByFilter<ProductRow>(
      indexName, "score = 0", ROW_ATTRIBUTES
    );
    const reanalyze = noData
      .filter((r) => isStale(r.lastAnalysisAttempt) && (r.name || r.brand))
      // Oldest attempt first, so the same few rows don't hog every night.
      .sort((a, b) => (a.lastAnalysisAttempt ?? 0) - (b.lastAnalysisAttempt ?? 0))
      .slice(0, config.selfHeal.reanalyzePerRun);
    summary.reanalyzeCandidates = reanalyze.length;
    logger.info("self-heal: reanalyze candidates", {
      runId, total: noData.length, selected: reanalyze.length, dryRun,
      sample: reanalyze.slice(0, 5).map((r) => `${r.brand} | ${r.name}`),
      structuredData: true,
    });

    if (!dryRun) {
      await mapPool(reanalyze, config.selfHeal.reanalyzeConcurrency, async (row) => {
        if (!withinBudget()) {
          summary.budgetExhausted = true;
          return;
        }
        summary.reanalyzed++;
        const key = row.objectID;
        try {
          const {product} = await analyzeProductImageParallel(
            null,
            "image/jpeg",
            {brand: row.brand, name: row.name, foodType: row.foodType},
            undefined,
            `${runId}-${key}`,
            row.gtin
          );
          if (product && product.score > 0) {
            summary.recovered++;
            await cacheProduct(key, {
              ...product,
              barcode: key,
              isAiIdentified: true,
              imageUrl: row.imageUrl || product.imageUrl || "",
              gtin: row.gtin,
              analysisSource: "web",
              lastAnalysisAttempt: Date.now(),
              lastImageAttempt: row.lastImageAttempt,
              translations: undefined,
            });
          } else {
            await partialUpdateRecord(indexName, key, {
              lastAnalysisAttempt: Date.now(),
            });
          }
        } catch (error) {
          logger.warn("self-heal: reanalyze failed", {
            runId, key,
            error: error instanceof Error ? error.message : String(error),
            structuredData: true,
          });
          await partialUpdateRecord(indexName, key, {lastAnalysisAttempt: Date.now()});
        }
      });
    }

    // ---- Pass 2: image backfill for products with data and no image ---------
    const withData = await fetchRowsByFilter<ProductRow>(
      indexName, "score > 0", ROW_ATTRIBUTES
    );
    const imageless = withData
      .filter((r) => !r.imageUrl && isStale(r.lastImageAttempt))
      .sort((a, b) => (a.lastImageAttempt ?? 0) - (b.lastImageAttempt ?? 0))
      .slice(0, config.selfHeal.imageBackfillPerRun);
    summary.imageCandidates = imageless.length;
    logger.info("self-heal: image candidates", {
      runId, selected: imageless.length, dryRun, structuredData: true,
    });

    if (!dryRun) {
      await mapPool(imageless, config.selfHeal.imageBackfillConcurrency, async (row) => {
        if (!withinBudget()) {
          summary.budgetExhausted = true;
          return;
        }
        summary.imagesAttempted++;
        const key = row.objectID;
        let hosted = "";
        try {
          const url = await findProductImageUrl(row.brand, row.name);
          if (url) hosted = await processProductImage(url, key, row.name, row.brand);
        } catch (error) {
          logger.warn("self-heal: image backfill failed", {
            runId, key,
            error: error instanceof Error ? error.message : String(error),
            structuredData: true,
          });
        }
        if (hosted) summary.imagesFound++;
        await partialUpdateRecord(indexName, key, {
          ...(hosted ? {imageUrl: hosted} : {}),
          lastImageAttempt: Date.now(),
        });
      });
    }

    // ---- Litter: the same two passes, smaller caps ---------------------------
    const litterNoData = await fetchRowsByFilter<LitterRow>(
      litterIndexName, "score = 0", ROW_ATTRIBUTES
    );
    const litterReanalyze = litterNoData
      .filter((r) => isStale(r.lastAnalysisAttempt) && (r.name || r.brand))
      .slice(0, config.selfHeal.litterReanalyzePerRun);
    summary.litterReanalyzeCandidates = litterReanalyze.length;

    if (!dryRun) {
      await mapPool(litterReanalyze, 2, async (row) => {
        if (!withinBudget()) {
          summary.budgetExhausted = true;
          return;
        }
        summary.litterReanalyzed++;
        const key = row.objectID;
        try {
          const {litter} = await analyzeLitterImage(
            null,
            "image/jpeg",
            {brand: row.brand, name: row.name},
            undefined,
            `${runId}-${key}`,
            row.gtin
          );
          if (litter && litter.score > 0) {
            summary.litterRecovered++;
            await cacheLitter(key, {
              ...litter,
              id: key,
              isAiIdentified: true,
              imageUrl: row.imageUrl || litter.imageUrl || "",
              gtin: row.gtin,
              lastAnalysisAttempt: Date.now(),
              lastImageAttempt: row.lastImageAttempt,
              translations: undefined,
            });
          } else {
            await partialUpdateRecord(litterIndexName, key, {
              lastAnalysisAttempt: Date.now(),
            });
          }
        } catch (error) {
          logger.warn("self-heal: litter reanalyze failed", {
            runId, key,
            error: error instanceof Error ? error.message : String(error),
            structuredData: true,
          });
          await partialUpdateRecord(litterIndexName, key, {
            lastAnalysisAttempt: Date.now(),
          });
        }
      });
    }

    const litterWithData = await fetchRowsByFilter<LitterRow>(
      litterIndexName, "score > 0", ROW_ATTRIBUTES
    );
    const litterImageless = litterWithData
      .filter((r) => !r.imageUrl && isStale(r.lastImageAttempt))
      .slice(0, config.selfHeal.litterImageBackfillPerRun);
    summary.litterImageCandidates = litterImageless.length;

    if (!dryRun) {
      await mapPool(litterImageless, 3, async (row) => {
        if (!withinBudget()) {
          summary.budgetExhausted = true;
          return;
        }
        const key = row.objectID;
        let hosted = "";
        try {
          const url = await findProductImageUrl(row.brand, row.name);
          if (url) hosted = await processProductImage(url, key, row.name, row.brand);
        } catch (error) {
          logger.warn("self-heal: litter image backfill failed", {
            runId, key,
            error: error instanceof Error ? error.message : String(error),
            structuredData: true,
          });
        }
        if (hosted) summary.litterImagesFound++;
        await partialUpdateRecord(litterIndexName, key, {
          ...(hosted ? {imageUrl: hosted} : {}),
          lastImageAttempt: Date.now(),
        });
      });
    }

    summary.ms = Date.now() - started;
    logger.info("self-heal summary", {runId, ...summary, structuredData: true});
  }
);

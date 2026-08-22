import Anthropic from "@anthropic-ai/sdk";
import * as logger from "firebase-functions/logger";
import {config} from "../config";
import {RETRY_CONFIG} from "../constants";
import {FoodType, Product, ProductModel, ProductText} from "../models/product";
import {
  LITTER_LEVELS,
  LITTER_MATERIALS,
  Litter,
  LitterModel,
  TRISTATES,
} from "../models/litter";
import {RecipeIngredient, RecipeText} from "../models/recipe";
import {generateIdentificationPrompt} from "../prompts/identify-product";
import {
  generateLitterAnalysisSystemPrompt,
  generateLitterAnalysisUserPrompt,
} from "../prompts/analyze-litter";
import {generateTranslationSystemPrompt, generateTranslationUserPrompt} from "../prompts/translate-product";
import {
  generateRecipeTranslationSystemPrompt,
  generateRecipeTranslationUserPrompt,
} from "../prompts/translate-recipe";
import {languageName} from "../prompts/languages";
import {
  generateAnalysisSystemPrompt,
  generateAnalysisUserPrompt,
} from "../prompts/analyze-product";
import {
  CatNarrativeInput,
  generateCatNarrativeSystemPrompt,
  generateCatNarrativeUserPrompt,
} from "../prompts/cat-narrative";
import {
  RegradeInput,
  generateRegradeSystemPrompt,
  generateRegradeUserPrompt,
} from "../prompts/rescore-product";
import {
  BrandVerdictInput,
  generateBrandVerdictSystemPrompt,
  generateBrandVerdictUserPrompt,
} from "../prompts/brand-verdict";
import {isImageUrlValid} from "./image.service";
import {searchProductImageUrls, searchProductPageUrls} from "./serpapi.service";
import {fetchPage, fetchPageText} from "../utils/page-fetch";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let anthropicClient: any = null;

function getClient(): Anthropic {
  if (!anthropicClient) {
    if (!config.anthropic.apiKey) {
      throw new Error(
        "ANTHROPIC_API_KEY is not set. Configure via " +
        "`firebase functions:secrets:set ANTHROPIC_API_KEY` and declare " +
        "`secrets: [\"ANTHROPIC_API_KEY\"]` in the onCall runtime options."
      );
    }
    anthropicClient = new Anthropic({apiKey: config.anthropic.apiKey});
  }
  return anthropicClient;
}

const SUPPORTED_MEDIA_TYPES = new Set<string>([
  "image/jpeg",
  "image/png",
  "image/gif",
  "image/webp",
]);

type AnthropicMediaType = "image/jpeg" | "image/png" | "image/gif" | "image/webp";

function normalizeMediaType(mimeType: string): AnthropicMediaType {
  if (SUPPORTED_MEDIA_TYPES.has(mimeType)) {
    return mimeType as AnthropicMediaType;
  }
  return "image/jpeg";
}

/**
 * Retries an async operation with exponential backoff on transient failures
 * (5xx, 429). Mirrors the yucat-api Gemini retry pattern.
 */
async function withRetry<T>(
  label: string,
  fn: () => Promise<T>
): Promise<T> {
  let lastError: unknown;
  for (let attempt = 0; attempt <= RETRY_CONFIG.MAX_RETRIES; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      const status = (error as {status?: number})?.status;
      const isRetryable = status === 429 || (status !== undefined && status >= 500);
      const willRetry = isRetryable && attempt < RETRY_CONFIG.MAX_RETRIES;

      logger.warn("Anthropic call failed", {
        label,
        attempt: attempt + 1,
        status: status ?? "unknown",
        willRetry,
        error: error instanceof Error ? error.message : String(error),
        structuredData: true,
      });

      if (!willRetry) {
        break;
      }
      const wait = RETRY_CONFIG.BASE_WAIT_TIME_MS * Math.pow(2, attempt);
      await new Promise((resolve) => setTimeout(resolve, wait));
    }
  }
  throw lastError;
}

export interface ProductIdentification {
  brand: string;
  name: string;
  foodType: FoodType;
}

export interface LitterIdentification {
  brand: string;
  name: string;
}

/**
 * What the identify step decided the photo shows. The scan pipeline branches on
 * `category`, so adding a third scannable category means adding a variant here
 * and one more tool below — nothing else in the pipeline is category-aware.
 */
export type ScanIdentification =
  | {category: "food"; food: ProductIdentification}
  | {category: "litter"; litter: LitterIdentification};

const FOOD_TYPE_ENUM: FoodType[] = [
  "wet", "dry", "treat", "topper", "supplement",
];

const IDENTIFICATION_TOOLS: Anthropic.Tool[] = [
  {
    name: "submit_identification",
    description:
      "Submit the identified cat food product. Call this when the image " +
      "clearly shows a cat food product.",
    input_schema: {
      type: "object",
      required: ["brand", "name", "foodType"],
      properties: {
        brand: {type: "string", description: "Brand name from packaging"},
        name: {
          type: "string",
          description: "Full product name including line, flavor, variant",
        },
        foodType: {type: "string", enum: FOOD_TYPE_ENUM},
      },
    },
  },
  {
    name: "submit_litter_identification",
    description:
      "Submit the identified cat litter product. Call this when the image " +
      "clearly shows cat litter (the substrate that goes in a litter box).",
    input_schema: {
      type: "object",
      required: ["brand", "name"],
      properties: {
        brand: {type: "string", description: "Brand name from packaging"},
        name: {
          type: "string",
          description: "Full product name including line and variant",
        },
      },
    },
  },
  {
    name: "not_cat_product",
    description:
      "Call this if the image is neither cat food nor cat litter (dog food, " +
      "human food, other non-cat items, or unrecognizable).",
    input_schema: {type: "object", properties: {}},
  },
];

const LITTER_ANALYSIS_TOOLS: Anthropic.Tool[] = [
  {
    name: "submit_litter",
    description: "Submit the final cat litter analysis.",
    input_schema: {
      type: "object",
      required: [
        "name", "brand", "material", "clumping", "dustLevel", "scented",
        "trackingLevel", "odorControl", "flushable", "biodegradable",
        "additives", "format", "packageSize", "description", "imageUrl",
        "score", "pros", "cons",
      ],
      properties: {
        name: {type: "string"},
        brand: {type: "string"},
        material: {
          type: "string",
          enum: LITTER_MATERIALS,
          description:
            "Substrate. \"clay-bentonite\" for clumping sodium bentonite " +
            "clay, \"clay-non-clumping\" for traditional absorbent clay, " +
            "\"mixed\" for a genuine blend, \"other\" only when it is none " +
            "of the listed substrates.",
        },
        clumping: {
          type: "string",
          enum: TRISTATES,
          description: "Does it form scoopable clumps?",
        },
        dustLevel: {
          type: "string",
          enum: LITTER_LEVELS,
          description:
            "Airborne dust. \"low\" only when the product claims dust-free / " +
            "low dust or the substrate is inherently low dust.",
        },
        scented: {
          type: "string",
          enum: TRISTATES,
          description: "Does it contain added fragrance or perfume?",
        },
        trackingLevel: {type: "string", enum: LITTER_LEVELS},
        odorControl: {
          type: "string",
          enum: LITTER_LEVELS,
          description:
            "How effectively it controls odour: low = weak, high = strong.",
        },
        flushable: {type: "string", enum: TRISTATES},
        biodegradable: {type: "string", enum: TRISTATES},
        additives: {
          type: "array",
          items: {type: "string"},
          description:
            "Functional additives named on the label, e.g. \"Baking soda\", " +
            "\"Activated charcoal\", \"Fragrance\". Empty array if none.",
        },
        format: {
          type: "string",
          description:
            "Short display-friendly format, e.g. \"Clumping bentonite clay\", " +
            "\"Silica crystals\", \"Tofu pellets\". Title case, max 28 chars.",
        },
        packageSize: {
          type: "string",
          description:
            "Pack size as printed, e.g. \"10 L bag\", \"12.7 kg box\". " +
            "Empty string if not visible.",
        },
        description: {
          type: "string",
          description:
            "2-3 sentence factual summary of what the litter is made of and " +
            "how it behaves in the box. No marketing language.",
        },
        imageUrl: {type: "string"},
        score: {
          type: "number",
          minimum: 0,
          maximum: 100,
          description:
            "0 is the \"no data found\" sentinel, NOT a bad grade. Any litter " +
            "you could characterize scores at least 1.",
        },
        pros: {type: "array", items: {type: "string"}, maxItems: 3},
        cons: {type: "array", items: {type: "string"}, maxItems: 3},
      },
    },
  },
];

const ANALYSIS_TOOLS: Anthropic.Tool[] = [
  {
    name: "submit_product",
    description: "Submit the final cat food product analysis.",
    input_schema: {
      type: "object",
      required: [
        "name", "brand", "foodType", "format", "packageSize", "description",
        "protein", "fat", "moisture", "carbs", "fiber", "ash",
        "imageUrl", "score", "pros", "cons", "ingredients",
      ],
      properties: {
        name: {type: "string"},
        brand: {type: "string"},
        foodType: {type: "string", enum: FOOD_TYPE_ENUM},
        format: {
          type: "string",
          description:
            "Short display-friendly format e.g. \"Wet pâté\", \"Dry kibble\", " +
            "\"Crunchy treats\". Title case, max 24 chars.",
        },
        packageSize: {
          type: "string",
          description:
            "Pack size as printed on packaging, e.g. \"85g pouch\", " +
            "\"12 lb bag\", \"6 x 70g multipack\". Empty string if not visible.",
        },
        description: {
          type: "string",
          description:
            "2-3 sentence nutrition-focused summary describing the product " +
            "and its key characteristics for an average healthy adult cat. " +
            "No marketing language.",
        },
        protein: {type: "number", minimum: 0, maximum: 100},
        fat: {type: "number", minimum: 0, maximum: 100},
        moisture: {type: "number", minimum: 0, maximum: 100},
        carbs: {type: "number", minimum: 0, maximum: 100},
        fiber: {type: "number", minimum: 0, maximum: 100},
        ash: {type: "number", minimum: 0, maximum: 100},
        imageUrl: {type: "string"},
        score: {type: "number", minimum: 0, maximum: 100},
        pros: {type: "array", items: {type: "string"}, maxItems: 3},
        cons: {type: "array", items: {type: "string"}, maxItems: 3},
        ingredients: {
          type: "array",
          items: {type: "string"},
          description:
            "Ingredients list as printed on the label, in order, each an " +
            "individual item (e.g. \"Fresh chicken (50%)\", \"Sweet potato\", " +
            "\"Pea\"). Empty array if not found.",
        },
      },
    },
  },
];

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function findToolUse(content: any[], name: string): any | undefined {
  return content.find(
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (block: any) => block?.type === "tool_use" && block?.name === name
  );
}

/**
 * Step 1 — Quick identification from the photo. No web search.
 * Returns null if the image is not a cat food product.
 */
/**
 * Step 1 — fast classification + transcription. Decides whether the photo shows
 * cat food, cat litter, or neither, and reads the brand/name off the packaging.
 * No web search: this step must stay cheap because every scan pays for it.
 */
export async function identifyScanSubject(
  imageBase64: string,
  mimeType: string
): Promise<ScanIdentification | null> {
  const mediaType = normalizeMediaType(mimeType);
  const prompt = generateIdentificationPrompt();

  const response = await withRetry("identifyScanSubject", () =>
    getClient().messages.create({
      model: config.anthropic.model,
      max_tokens: 256,
      temperature: config.anthropic.temperature,
      messages: [
        {
          role: "user",
          content: [
            {
              type: "image",
              source: {type: "base64", media_type: mediaType, data: imageBase64},
            },
            {type: "text", text: prompt},
          ],
        },
      ],
      tools: IDENTIFICATION_TOOLS,
      tool_choice: {type: "any"},
    })
  );

  const submit = findToolUse(response.content, "submit_identification");
  if (submit) {
    const input = submit.input as ProductIdentification;
    logger.info("Product identified", {
      category: "food",
      brand: input.brand,
      name: input.name,
      foodType: input.foodType,
      structuredData: true,
    });
    return {category: "food", food: input};
  }

  const submitLitter = findToolUse(
    response.content,
    "submit_litter_identification"
  );
  if (submitLitter) {
    const input = submitLitter.input as LitterIdentification;
    logger.info("Product identified", {
      category: "litter",
      brand: input.brand,
      name: input.name,
      structuredData: true,
    });
    return {category: "litter", litter: input};
  }

  const notCatProduct = findToolUse(response.content, "not_cat_product");
  if (notCatProduct) {
    logger.info("Image classified as non-cat-product", {structuredData: true});
    return null;
  }

  logger.warn("Identification call returned no tool_use", {
    stopReason: response.stop_reason,
    structuredData: true,
  });
  return null;
}

// web_search is a server-side tool: when its internal loop pauses, the API
// returns stop_reason "pause_turn" with NO submit_product block yet. We must
// re-send the assistant turn to resume. This caps how many times we resume.
const MAX_CONTINUATIONS = 3;

/**
 * Step 2 — Full analysis with Anthropic web_search. Returns a Product on
 * success, or null if the model could not produce a structured answer.
 *
 * web_search_20250305 is a server-side tool. It does NOT always resolve in a
 * single round trip: the response can come back with stop_reason "pause_turn"
 * (search loop paused, mid-task) or "max_tokens" (output truncated before the
 * final tool call) and therefore no submit_product block. We resume on
 * "pause_turn", and if the search path still yields nothing we fall back to a
 * forced submit_product call with no web search so a real, on-label product is
 * never silently dropped to null.
 */
export async function analyzeProductImage(
  imageBase64: string,
  mimeType: string,
  identification?: ProductIdentification,
  countryCode?: string
): Promise<{product: Product | null; rawResponse: string}> {
  // Run the web_search source and the manufacturer-page source concurrently,
  // then keep the most complete (pickBestProduct). The page source overlaps the
  // search instead of waiting behind it.
  const [web, pages] = await Promise.all([
    analyzeOneSource(imageBase64, mimeType, identification, {
      maxUses: config.anthropic.maxWebSearches,
      label: "single",
      countryCode,
    }),
    analyzeFromManufacturerPages(imageBase64, mimeType, identification),
  ]);
  const results = [web, pages].filter((r): r is AnalyzeResult => r !== null);
  return pickBestProduct(results);
}

interface AnalyzeSourceOptions {
  /** Restrict the search to one source (manufacturer / a retailer). */
  sourceHint?: string;
  /** web_search max_uses for this call. */
  maxUses?: number;
  /** Log label to distinguish parallel instances. */
  label?: string;
  /**
   * Device country (ISO 3166-1 alpha-2, e.g. "ES") used to bias web_search
   * results toward the user's market. When set, surfaces region-appropriate
   * manufacturer/retailer pages instead of US-defaulted results — critical for
   * niche non-US brands whose nutrition lives on their own localized site.
   */
  countryCode?: string;
}

/**
 * Runs one analyze call. With a `sourceHint` + small `maxUses` this is a fast,
 * single-source instance used by {@link analyzeProductImageParallel}; with no
 * hint it is the original free-search behavior (the control path).
 */
async function analyzeOneSource(
  imageBase64: string,
  mimeType: string,
  identification: ProductIdentification | undefined,
  opts: AnalyzeSourceOptions
): Promise<{product: Product | null; rawResponse: string}> {
  const label = opts.label ?? "single";
  const maxUses = opts.maxUses ?? config.anthropic.maxWebSearches;
  // Mutable: web_search only accepts an allowlist of country codes (e.g. AE is
  // rejected). On an "unsupported country" 400 we clear this and retry without
  // user_location, so an unsupported region degrades to no-biasing instead of
  // failing the whole scan.
  let country = opts.countryCode?.trim().toUpperCase() || undefined;
  const mediaType = normalizeMediaType(mimeType);
  const systemText = generateAnalysisSystemPrompt();
  const userText = generateAnalysisUserPrompt(identification, opts.sourceHint);

  const systemBlocks = [
    {
      type: "text" as const,
      text: systemText,
      cache_control: {type: "ephemeral" as const},
    },
  ];

  const userContent: Anthropic.MessageParam["content"] = [
    {
      type: "image",
      source: {type: "base64", media_type: mediaType, data: imageBase64},
    },
    {type: "text", text: userText},
  ];

  // Resume loop: continue the turn while the server-side search tool pauses.
  const messages: Anthropic.MessageParam[] = [
    {role: "user", content: userContent},
  ];
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let accumulated: any[] = [];
  let lastStopReason: string | null | undefined;

  // Timing instrumentation: capture per-round-trip latency so we can see whether
  // the analyze cost is one slow search, many pause_turn resumes, or the fallback.
  const roundTripMs: number[] = [];
  const stopReasons: (string | null | undefined)[] = [];
  // Token usage tells us whether the time is reading-bound (large input from
  // search results) or generation-bound (large output) — the key question for
  // whether splitting work across parallel instances helps.
  let inputTokens = 0;
  let outputTokens = 0;

  // Builds the request with the web_search tool, biased to `country` when set.
  const createParams = () => ({
    model: config.anthropic.model,
    max_tokens: 8192,
    temperature: config.anthropic.temperature,
    system: systemBlocks,
    messages,
    tools: [
      {
        type: "web_search_20250305",
        name: "web_search",
        max_uses: maxUses,
        // Bias results to the user's country when known (e.g. surface a
        // Spanish brand's .es pages for an ES user). Omitted when absent so
        // global/US brands are unaffected.
        ...(country ?
          {user_location: {type: "approximate", country}} :
          {}),
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      } as any,
      ...ANALYSIS_TOOLS,
    ],
    tool_choice: {type: "auto" as const},
  });

  // web_search rejects unsupported country codes with a 400. user_location is a
  // best-effort enhancement, so drop it and retry rather than fail the analyze.
  const isUnsupportedCountryError = (err: unknown): boolean =>
    /country code/i.test(err instanceof Error ? err.message : String(err));

  for (let i = 0; i <= MAX_CONTINUATIONS; i++) {
    const roundStart = Date.now();
    let response;
    try {
      response = await withRetry("analyzeProductImage", () =>
        getClient().messages.create(createParams())
      );
    } catch (err) {
      if (country && isUnsupportedCountryError(err)) {
        logger.warn("web_search rejected country; retrying without biasing", {
          label,
          country,
          structuredData: true,
        });
        country = undefined;
        response = await withRetry("analyzeProductImage", () =>
          getClient().messages.create(createParams())
        );
      } else {
        throw err;
      }
    }
    roundTripMs.push(Date.now() - roundStart);
    stopReasons.push(response.stop_reason);
    inputTokens += response.usage?.input_tokens ?? 0;
    outputTokens += response.usage?.output_tokens ?? 0;

    accumulated = accumulated.concat(response.content);
    lastStopReason = response.stop_reason;

    // "pause_turn" predates the pinned SDK's StopReason union — compare as string.
    if ((response.stop_reason as string) === "pause_turn") {
      // Server tool loop paused — re-send the assistant turn to resume.
      messages.push({role: "assistant", content: response.content});
      continue;
    }
    break;
  }

  // Count the actual web searches the model ran (server_tool_use blocks named
  // "web_search"). Combined with roundTrips + webSearchMs, this tells us whether
  // searches ran sequentially (time scales with count) or were batched/parallel.
  const webSearchCount = accumulated.filter(
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (b: any) => b?.type === "server_tool_use" && b?.name === "web_search"
  ).length;

  logger.info("analyzeProductImage web_search timing", {
    label,
    maxUses,
    country: country ?? "none",
    roundTrips: roundTripMs.length,
    roundTripMs,
    webSearchMs: roundTripMs.reduce((a, b) => a + b, 0),
    webSearchCount,
    inputTokens,
    outputTokens,
    stopReasons,
    structuredData: true,
  });

  let submit = findToolUse(accumulated, "submit_product");

  // Fallback — the search turn ended without a submit_product (commonly the
  // model wrote its analysis as free text and stopped with end_turn instead of
  // calling the tool). Rather than re-deriving from the image alone — which
  // throws away everything the searches just found — feed the research the model
  // already produced back in and force a submit_product call. Falls back to an
  // image-only submit if there's no usable prior text, so robustness is kept.
  if (!submit) {
    logger.warn(
      "analyzeProductImage: no submit_product from web search, forcing submit",
      {stopReason: lastStopReason, structuredData: true}
    );

    const priorText = accumulated
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      .filter((b: any) => b?.type === "text" && typeof b.text === "string")
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      .map((b: any) => b.text as string)
      .join("\n")
      .trim();

    const fallbackMessages: Anthropic.MessageParam[] = priorText ?
      [
        {role: "user", content: userContent},
        {
          role: "user",
          content:
            "Here is the research you already gathered for this product:\n\n" +
            priorText +
            "\n\nNow call the submit_product tool with the final structured " +
            "answer using this data. If guaranteed-analysis figures were not " +
            "found, submit with nutrient values at 0, score 0, and empty " +
            "pros/cons/ingredients — do not invent values.",
        },
      ] :
      [{role: "user", content: userContent}];

    const fallbackStart = Date.now();
    const fallback = await withRetry("analyzeProductImage:forceSubmit", () =>
      getClient().messages.create({
        model: config.anthropic.model,
        max_tokens: 4096,
        temperature: config.anthropic.temperature,
        system: systemBlocks,
        messages: fallbackMessages,
        tools: ANALYSIS_TOOLS,
        tool_choice: {type: "tool", name: "submit_product"},
      })
    );
    inputTokens += fallback.usage?.input_tokens ?? 0;
    outputTokens += fallback.usage?.output_tokens ?? 0;
    logger.info("analyzeProductImage fallback timing", {
      label,
      fallbackMs: Date.now() - fallbackStart,
      usedPriorText: !!priorText,
      structuredData: true,
    });

    submit = findToolUse(fallback.content, "submit_product");
    if (!submit) {
      logger.warn("analyzeProductImage fallback returned no submit_product", {
        stopReason: fallback.stop_reason,
        structuredData: true,
      });
      return {product: null, rawResponse: JSON.stringify(fallback.content)};
    }
  }

  const product = ProductModel.fromObject({
    ...submit.input,
    barcode: "",
  } as Partial<Product>).toObject();

  return {
    product,
    rawResponse: JSON.stringify(submit.input),
  };
}

type AnalyzeResult = {product: Product | null; rawResponse: string};

/**
 * Fan-out analysis: run several single-source instances concurrently and keep
 * the most complete result. This is true parallelism (independent API calls),
 * unlike the server-side web_search loop which serializes within one turn.
 */
export async function analyzeProductImageParallel(
  imageBase64: string,
  mimeType: string,
  identification?: ProductIdentification,
  countryCode?: string
): Promise<AnalyzeResult> {
  const SOURCES: {label: string; hint: string}[] = [
    {
      label: "manufacturer",
      hint:
        "the manufacturer's official website — find the brand's own domain " +
        "and open the specific product page (the maker often hosts the " +
        "guaranteed analysis when retailers do not)",
    },
    {label: "retailer-a", hint: "a major retailer such as Chewy or Amazon"},
    {
      label: "retailer-b",
      hint: "a major retailer such as zooplus, Petco, or Pets at Home",
    },
  ];

  const started = Date.now();
  const settled = await Promise.all([
    ...SOURCES.map((s) =>
      analyzeOneSource(imageBase64, mimeType, identification, {
        sourceHint: s.hint,
        maxUses: config.anthropic.parallelMaxUses,
        label: s.label,
        countryCode,
      }).catch((error) => {
        logger.warn("analyzeProductImageParallel instance failed", {
          label: s.label,
          error: error instanceof Error ? error.message : String(error),
          structuredData: true,
        });
        return null;
      })
    ),
    // 4th source: the manufacturer's product page fetched directly (location-
    // independent). Runs concurrently so it overlaps web_search rather than
    // waiting behind it. Ordered last so a completeness tie keeps the image-
    // grounded web_search result; the page wins only when it alone has nutrition.
    analyzeFromManufacturerPages(imageBase64, mimeType, identification),
  ]);
  const results = settled.filter((r): r is AnalyzeResult => r !== null);

  const best = pickBestProduct(results);
  logger.info("analyzeProductImageParallel complete", {
    instances: SOURCES.length + 1,
    succeeded: results.length,
    parallelMs: Date.now() - started,
    chosenHasNutrition: best.product ? best.product.score > 0 : false,
    structuredData: true,
  });
  return best;
}

/**
 * Picks the most complete analysis from the fan-out instances. Ranks by data
 * completeness (nutrition + ingredients), not image — the image is re-sourced
 * via SerpAPI downstream regardless. Results are in source-priority order
 * (manufacturer first), so strict-greater comparison keeps the earlier source
 * on ties.
 */
function pickBestProduct(results: AnalyzeResult[]): AnalyzeResult {
  const completeness = (p: Product | null): number => {
    if (!p) return -1;
    const hasNutrition = p.score > 0 ? 2 : 0;
    const hasIngredients = (p.ingredients?.length ?? 0) > 0 ? 1 : 0;
    return hasNutrition + hasIngredients;
  };

  let best: AnalyzeResult = results[0] ?? {product: null, rawResponse: ""};
  let bestScore = completeness(best.product);
  for (const r of results.slice(1)) {
    const s = completeness(r.product);
    if (s > bestScore) {
      best = r;
      bestScore = s;
    }
  }
  return best;
}

/**
 * Extraction-only analyze: given product page text already fetched from the web,
 * force a structured `submit_product` extraction. No web_search — the model
 * reads the supplied page text (anchored to the product image) and pulls out the
 * guaranteed analysis + ingredients. Returns null if no nutrition is recovered.
 */
async function analyzeFromProductPages(
  imageBase64: string,
  mimeType: string,
  identification: ProductIdentification | undefined,
  pages: {url: string; text: string}[]
): Promise<AnalyzeResult | null> {
  if (pages.length === 0) return null;

  const mediaType = normalizeMediaType(mimeType);
  const systemBlocks = [
    {
      type: "text" as const,
      text: generateAnalysisSystemPrompt(),
      cache_control: {type: "ephemeral" as const},
    },
  ];

  const known = identification ?
    `This product has been identified as brand "${identification.brand}", ` +
    `name "${identification.name}", foodType "${identification.foodType}". ` :
    "";

  const pagesBlock = pages
    .map((p, i) => `--- PAGE ${i + 1} (${p.url}) ---\n${p.text}`)
    .join("\n\n");

  const instruction =
    known +
    "Below are the text contents of web pages for this product. Do NOT search " +
    "the web — extract from the page text only. Find the guaranteed analysis " +
    "(protein, fat, fibre, moisture, ash) and the ingredients for THIS EXACT " +
    "product. Use only figures explicitly labelled as analytical constituents / " +
    "guaranteed analysis / composition (note: \"humidity\"/\"humedad\" = " +
    "moisture). Ignore any page that is about a different product or pack. If a " +
    "value is genuinely absent from every page, leave it at 0 — never invent " +
    "values. Then call submit_product with the structured result.\n\n" +
    pagesBlock;

  const userContent: Anthropic.MessageParam["content"] = [
    {
      type: "image",
      source: {type: "base64", media_type: mediaType, data: imageBase64},
    },
    {type: "text", text: instruction},
  ];

  const start = Date.now();
  const response = await withRetry("analyzeFromProductPages", () =>
    getClient().messages.create({
      model: config.anthropic.model,
      max_tokens: 4096,
      temperature: config.anthropic.temperature,
      system: systemBlocks,
      messages: [{role: "user", content: userContent}],
      tools: ANALYSIS_TOOLS,
      tool_choice: {type: "tool", name: "submit_product"},
    })
  );

  const submit = findToolUse(response.content, "submit_product");
  if (!submit) {
    logger.warn("analyzeFromProductPages: no submit_product returned", {
      structuredData: true,
    });
    return null;
  }

  const product = ProductModel.fromObject({
    ...submit.input,
    barcode: "",
  } as Partial<Product>).toObject();

  logger.info("analyzeFromProductPages complete", {
    pages: pages.length,
    ms: Date.now() - start,
    hasNutrition: product.score > 0,
    structuredData: true,
  });

  return {product, rawResponse: JSON.stringify(submit.input)};
}

/** Distinctive tokens of a product name, for matching against URL slugs. */
function nameTokens(s: string): string[] {
  const stop = new Set([
    "and", "the", "with", "for", "cat", "cats", "food", "wet", "dry", "pack",
  ]);
  return s
    .toLowerCase()
    .split(/[^a-z0-9]+/)
    .filter((t) => t.length >= 3 && !stop.has(t));
}

/** Count of name tokens present in a URL — higher = better product match. */
function slugMatchScore(url: string, tokens: string[]): number {
  const slug = url.toLowerCase();
  return tokens.reduce((n, t) => (slug.includes(t) ? n + 1 : n), 0);
}

/** Lowercased pathname for de-duping URLs that differ only by query string. */
function safePath(url: string): string {
  try {
    return new URL(url).pathname.toLowerCase();
  } catch {
    return url.toLowerCase();
  }
}

/**
 * Manufacturer-page source. Finds candidate product pages via SerpAPI, fetches
 * their text directly (bypassing Claude's web_search index, which misses niche
 * non-US brands), and extracts the guaranteed analysis from the page content.
 * Returns a complete result when nutrition is recovered, else null. Run
 * concurrently with the web_search fan-out as a first-class source — it's
 * location-independent, so it's the path that fixes niche brands. Never throws.
 */
async function analyzeFromManufacturerPages(
  imageBase64: string,
  mimeType: string,
  identification: ProductIdentification | undefined
): Promise<AnalyzeResult | null> {
  if (!config.anthropic.useManufacturerPageFallback) return null;

  const brand = identification?.brand || "";
  const name = identification?.name || "";
  if (!brand && !name) return null;

  const started = Date.now();
  try {
    const urls = await searchProductPageUrls(brand, name);
    if (urls.length === 0) return null;

    const primaryUrls = urls.slice(0, config.anthropic.pageFallbackMaxPages);
    const primary = await Promise.all(primaryUrls.map((u) => fetchPage(u)));

    // Search often surfaces a brand's collection/category page above the actual
    // product page. Follow the product-detail links those pages expose, ranked
    // by how well their slug matches the identified name, and fetch the best
    // couple — that's where the guaranteed analysis usually lives.
    const tokens = nameTokens(`${brand} ${name}`);
    const seenPaths = new Set(primaryUrls.map((u) => safePath(u)));
    const linkScores = new Map<string, number>();
    for (const page of primary) {
      for (const link of page.productLinks) {
        if (seenPaths.has(safePath(link))) continue;
        const score = slugMatchScore(link, tokens);
        if (score > (linkScores.get(link) ?? -1)) linkScores.set(link, score);
      }
    }
    const followUrls = [...linkScores.entries()]
      .filter(([, s]) => s >= 2)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 2)
      .map(([link]) => link);
    const followed = await Promise.all(followUrls.map((u) => fetchPageText(u)));

    // Drop pages that returned nothing usable (404, JS-only, blocked).
    const usable = (p: {url: string; text: string}) => p.text.length > 200;
    const followedPages = followUrls
      .map((url, i) => ({url, text: followed[i]}))
      .filter(usable);
    const primaryPages = primaryUrls
      .map((url, i) => ({url, text: primary[i].text}))
      .filter(usable);

    // Prefer the followed product-detail pages: they carry the guaranteed
    // analysis and avoid the token cost + wrong-product noise of feeding
    // collection/listing pages to the extractor. Fall back to the primary
    // search-result pages only when we couldn't follow any (e.g. SerpAPI already
    // returned the product page directly, or the site isn't a /products/ shop).
    const pages = (followedPages.length > 0 ? followedPages : primaryPages)
      .slice(0, config.anthropic.pageFallbackMaxPages);

    logger.info("manufacturer-page source: fetched pages", {
      brand,
      name,
      candidateUrls: urls.length,
      followedLinks: followUrls.length,
      fetchedPages: pages.length,
      structuredData: true,
    });
    if (pages.length === 0) return null;

    const result = await analyzeFromProductPages(
      imageBase64,
      mimeType,
      identification,
      pages
    );
    if (result?.product && result.product.score > 0) {
      logger.info("manufacturer-page source: nutrition recovered", {
        brand,
        name,
        totalMs: Date.now() - started,
        structuredData: true,
      });
      return result;
    }
    logger.info("manufacturer-page source: no nutrition in pages", {
      brand,
      name,
      totalMs: Date.now() - started,
      structuredData: true,
    });
    return null;
  } catch (error) {
    logger.warn("manufacturer-page source errored", {
      brand,
      name,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return null;
  }
}

const NARRATIVE_TOOLS: Anthropic.Tool[] = [
  {
    name: "submit_narrative",
    description:
      "Submit the finished personalized note + forward-looking outlook for the cat owner.",
    input_schema: {
      type: "object",
      required: ["narrative", "outlook"],
      properties: {
        narrative: {
          type: "string",
          description:
            "The warm, ~50 word personalized note that acknowledges the cat's conditions, in the requested language.",
        },
        outlook: {
          type: "string",
          description:
            "One forward-looking sentence (~25 words) about what the owner may notice in roughly two weeks, in the requested language.",
        },
      },
    },
  },
];

/**
 * Full litter analysis — one Haiku call with web_search, mirroring the shape of
 * {@link analyzeOneSource} (pause_turn resume loop, country biasing, forced
 * submit fallback) but deliberately NOT fanned out across sources.
 *
 * Litter attributes are a handful of qualitative facts printed on the pack and
 * repeated identically by every retailer, unlike a guaranteed analysis that one
 * source has and another doesn't. Parallel sources would triple the cost to
 * re-read the same claims, so a single free-search call at `maxWebSearches` is
 * the right trade here. Revisit if attribute coverage turns out to be thin.
 *
 * Returns `{litter: null}` only when the model produced no structured answer at
 * all; a litter it could not characterize comes back with score 0 and every
 * attribute "unknown".
 */
export async function analyzeLitterImage(
  imageBase64: string,
  mimeType: string,
  identification?: LitterIdentification,
  countryCode?: string
): Promise<{litter: Litter | null; rawResponse: string}> {
  // Mutable: web_search accepts only an allowlist of country codes, so an
  // unsupported region degrades to no biasing rather than failing the scan.
  let country = countryCode?.trim().toUpperCase() || undefined;
  const mediaType = normalizeMediaType(mimeType);

  const systemBlocks = [
    {
      type: "text" as const,
      text: generateLitterAnalysisSystemPrompt(),
      cache_control: {type: "ephemeral" as const},
    },
  ];

  const userContent: Anthropic.MessageParam["content"] = [
    {
      type: "image",
      source: {type: "base64", media_type: mediaType, data: imageBase64},
    },
    {type: "text", text: generateLitterAnalysisUserPrompt(identification)},
  ];

  const messages: Anthropic.MessageParam[] = [
    {role: "user", content: userContent},
  ];
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let accumulated: any[] = [];
  let lastStopReason: string | null | undefined;
  const roundTripMs: number[] = [];
  let inputTokens = 0;
  let outputTokens = 0;

  const createParams = () => ({
    model: config.anthropic.model,
    max_tokens: 8192,
    temperature: config.anthropic.temperature,
    system: systemBlocks,
    messages,
    tools: [
      {
        type: "web_search_20250305",
        name: "web_search",
        max_uses: config.anthropic.maxWebSearches,
        ...(country ?
          {user_location: {type: "approximate", country}} :
          {}),
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      } as any,
      ...LITTER_ANALYSIS_TOOLS,
    ],
    tool_choice: {type: "auto" as const},
  });

  const isUnsupportedCountryError = (err: unknown): boolean =>
    /country code/i.test(err instanceof Error ? err.message : String(err));

  for (let i = 0; i <= MAX_CONTINUATIONS; i++) {
    const roundStart = Date.now();
    let response;
    try {
      response = await withRetry("analyzeLitterImage", () =>
        getClient().messages.create(createParams())
      );
    } catch (err) {
      if (country && isUnsupportedCountryError(err)) {
        logger.warn("web_search rejected country; retrying without biasing", {
          label: "litter",
          country,
          structuredData: true,
        });
        country = undefined;
        response = await withRetry("analyzeLitterImage", () =>
          getClient().messages.create(createParams())
        );
      } else {
        throw err;
      }
    }
    roundTripMs.push(Date.now() - roundStart);
    inputTokens += response.usage?.input_tokens ?? 0;
    outputTokens += response.usage?.output_tokens ?? 0;
    accumulated = accumulated.concat(response.content);
    lastStopReason = response.stop_reason;

    // "pause_turn" predates the pinned SDK's StopReason union — compare as string.
    if ((response.stop_reason as string) === "pause_turn") {
      messages.push({role: "assistant", content: response.content});
      continue;
    }
    break;
  }

  logger.info("analyzeLitterImage web_search timing", {
    country: country ?? "none",
    roundTrips: roundTripMs.length,
    roundTripMs,
    webSearchMs: roundTripMs.reduce((a, b) => a + b, 0),
    webSearchCount: accumulated.filter(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      (b: any) => b?.type === "server_tool_use" && b?.name === "web_search"
    ).length,
    inputTokens,
    outputTokens,
    structuredData: true,
  });

  let submit = findToolUse(accumulated, "submit_litter");

  // Same fallback rationale as the food path: the search turn sometimes ends
  // with the answer written as free text and no tool call. Feed that research
  // back in and force the tool rather than throwing the searches away.
  if (!submit) {
    logger.warn("analyzeLitterImage: no submit_litter, forcing submit", {
      stopReason: lastStopReason,
      structuredData: true,
    });

    const priorText = accumulated
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      .filter((b: any) => b?.type === "text" && typeof b.text === "string")
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      .map((b: any) => b.text as string)
      .join("\n")
      .trim();

    const fallbackMessages: Anthropic.MessageParam[] = priorText ?
      [
        {role: "user", content: userContent},
        {
          role: "user",
          content:
            "Here is the research you already gathered for this litter:\n\n" +
            priorText +
            "\n\nNow call the submit_litter tool with the final structured " +
            "answer using this data. Leave attributes \"unknown\" and score 0 " +
            "if nothing was established — do not invent values.",
        },
      ] :
      [{role: "user", content: userContent}];

    const fallback = await withRetry("analyzeLitterImage:forceSubmit", () =>
      getClient().messages.create({
        model: config.anthropic.model,
        max_tokens: 4096,
        temperature: config.anthropic.temperature,
        system: systemBlocks,
        messages: fallbackMessages,
        tools: LITTER_ANALYSIS_TOOLS,
        tool_choice: {type: "tool", name: "submit_litter"},
      })
    );

    submit = findToolUse(fallback.content, "submit_litter");
    if (!submit) {
      logger.warn("analyzeLitterImage fallback returned no submit_litter", {
        stopReason: fallback.stop_reason,
        structuredData: true,
      });
      return {litter: null, rawResponse: JSON.stringify(fallback.content)};
    }
  }

  const litter = LitterModel.fromObject({
    ...submit.input,
    id: "",
  } as Partial<Litter>).toObject();

  return {litter, rawResponse: JSON.stringify(submit.input)};
}

export interface CatNarrativeResult {
  narrative: string;
  outlook: string | null;
}

/**
 * Onboarding narrative — a short, warm, personalized note plus a forward-looking
 * "~2 weeks" outlook for a freshly created cat profile. One Haiku call, no web
 * search; the structured dietary tips, condition care-notes, and combos ground
 * the prose so the model speaks to THIS cat without inventing claims. Returns
 * null on failure so the client can fall back to a local template.
 */
export async function generateCatNarrative(
  input: CatNarrativeInput
): Promise<CatNarrativeResult | null> {
  if (!input?.name) return null;

  const systemText = generateCatNarrativeSystemPrompt();
  const userText = generateCatNarrativeUserPrompt(input);

  try {
    const response = await withRetry("generateCatNarrative", () =>
      getClient().messages.create({
        model: config.anthropic.model,
        max_tokens: 400,
        temperature: 0.7,
        system: [
          {
            type: "text",
            text: systemText,
            cache_control: {type: "ephemeral"},
          },
        ],
        messages: [{role: "user", content: [{type: "text", text: userText}]}],
        tools: NARRATIVE_TOOLS,
        tool_choice: {type: "tool", name: "submit_narrative"},
      })
    );

    const submit = findToolUse(response.content, "submit_narrative");
    const narrative = submit?.input?.narrative;
    const outlook = submit?.input?.outlook;
    if (typeof narrative === "string" && narrative.trim() !== "") {
      logger.info("Cat narrative generated", {
        name: input.name,
        locale: input.locale ?? "en",
        length: narrative.trim().length,
        hasOutlook: typeof outlook === "string" && outlook.trim() !== "",
        structuredData: true,
      });
      return {
        narrative: narrative.trim(),
        outlook: typeof outlook === "string" && outlook.trim() !== "" ?
          outlook.trim() :
          null,
      };
    }

    logger.warn("generateCatNarrative returned no narrative", {
      stopReason: response.stop_reason,
      structuredData: true,
    });
    return null;
  } catch (error) {
    logger.warn("generateCatNarrative failed", {
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return null;
  }
}

const SCORE_TOOLS: Anthropic.Tool[] = [
  {
    name: "submit_score",
    description: "Submit the product's 0-100 nutritional quality score.",
    input_schema: {
      type: "object",
      required: ["score"],
      properties: {
        score: {
          type: "number",
          minimum: 0,
          maximum: 100,
          description: "Nutritional quality score, 0-100.",
        },
      },
    },
  },
];

/**
 * Re-grades a product's nutritional quality (0-100) from its stored facts using
 * the shared QUALITY_RUBRIC. One Haiku call, no web search. Returns the new
 * score, or null on failure (caller keeps the existing score).
 */
export async function regradeProductQuality(
  input: RegradeInput
): Promise<number | null> {
  try {
    const response = await withRetry("regradeProductQuality", () =>
      getClient().messages.create({
        model: config.anthropic.model,
        max_tokens: 128,
        temperature: 0,
        // Cache the (constant) rubric system prompt so the ~700-token rubric
        // isn't re-billed on every product during the batch re-score.
        system: [
          {
            type: "text",
            text: generateRegradeSystemPrompt(),
            cache_control: {type: "ephemeral"},
          },
        ],
        messages: [
          {role: "user", content: [
            {type: "text", text: generateRegradeUserPrompt(input)},
          ]},
        ],
        tools: SCORE_TOOLS,
        tool_choice: {type: "tool", name: "submit_score"},
      })
    );

    const submit = findToolUse(response.content, "submit_score");
    const score = submit?.input?.score;
    if (typeof score === "number" && isFinite(score)) {
      return Math.max(0, Math.min(100, Math.round(score)));
    }
    return null;
  } catch (error) {
    logger.warn("regradeProductQuality failed", {
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return null;
  }
}

const TRANSLATION_TOOLS: Anthropic.Tool[] = [
  {
    name: "submit_translation",
    description: "Submit the translated product text.",
    input_schema: {
      type: "object",
      required: ["format", "packageSize", "description", "pros", "cons"],
      properties: {
        format: {
          type: "string",
          description: "Translated short display format label, max 24 chars.",
        },
        packageSize: {
          type: "string",
          description:
            "Translated pack size. Numbers and units unchanged; only the " +
            "surrounding noun is translated.",
        },
        description: {
          type: "string",
          description: "Translated 2-3 sentence description.",
        },
        pros: {
          type: "array",
          items: {type: "string"},
          description: "Translated pros — same count and order as the source.",
        },
        cons: {
          type: "array",
          items: {type: "string"},
          description: "Translated cons — same count and order as the source.",
        },
      },
    },
  },
];

/**
 * Translates the five renderable product-text fields into [language].
 *
 * One small Haiku call, no web search. Returns null on any failure or if the
 * model changed the pros/cons item counts (a structural mismatch would desync
 * the client's chip rows from the English canonical), so the caller can fall
 * back to English. Never throws.
 */
export async function translateProductText(
  text: ProductText,
  languageCode: string
): Promise<ProductText | null> {
  const language = languageName(languageCode);
  const started = Date.now();
  try {
    const response = await withRetry("translateProductText", () =>
      getClient().messages.create({
        model: config.anthropic.model,
        max_tokens: 1024,
        temperature: 0,
        // The system prompt is constant, so it stays cacheable across every
        // language; the target language rides in the user message.
        system: [
          {
            type: "text",
            text: generateTranslationSystemPrompt(),
            cache_control: {type: "ephemeral"},
          },
        ],
        messages: [
          {role: "user", content: [
            {
              type: "text",
              text: generateTranslationUserPrompt(text, language),
            },
          ]},
        ],
        tools: TRANSLATION_TOOLS,
        tool_choice: {type: "tool", name: "submit_translation"},
      })
    );

    const submit = findToolUse(response.content, "submit_translation");
    const out = submit?.input;
    if (!out) return null;

    const pros = Array.isArray(out.pros) ? out.pros.map(String) : [];
    const cons = Array.isArray(out.cons) ? out.cons.map(String) : [];
    if (pros.length !== text.pros.length || cons.length !== text.cons.length) {
      logger.warn("translateProductText item-count mismatch — discarding", {
        languageCode,
        expectedPros: text.pros.length,
        gotPros: pros.length,
        expectedCons: text.cons.length,
        gotCons: cons.length,
        structuredData: true,
      });
      return null;
    }

    logger.info("translateProductText complete", {
      languageCode,
      ms: Date.now() - started,
      inputTokens: response.usage?.input_tokens,
      outputTokens: response.usage?.output_tokens,
      structuredData: true,
    });

    return {
      format: typeof out.format === "string" ? out.format : text.format,
      packageSize:
        typeof out.packageSize === "string" ?
          out.packageSize :
          text.packageSize,
      description:
        typeof out.description === "string" ?
          out.description :
          text.description,
      pros,
      cons,
    };
  } catch (error) {
    logger.warn("translateProductText failed", {
      languageCode,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return null;
  }
}

const RECIPE_TRANSLATION_TOOLS: Anthropic.Tool[] = [
  {
    name: "submit_recipe_translation",
    description: "Submit the translated recipe text.",
    input_schema: {
      type: "object",
      required: ["name", "description", "ingredients", "steps", "tip"],
      properties: {
        name: {type: "string", description: "Translated recipe name."},
        description: {
          type: "string",
          description: "Translated short description, same length as source.",
        },
        ingredients: {
          type: "array",
          description:
            "Translated ingredients \u2014 same count and order as the source.",
          items: {
            type: "object",
            required: ["name", "quantity"],
            properties: {
              name: {type: "string", description: "Translated ingredient."},
              quantity: {
                type: "string",
                description:
                  "Quantity phrase. Numbers and units unchanged; only the " +
                  "wording is translated.",
              },
            },
          },
        },
        steps: {
          type: "array",
          items: {type: "string"},
          description:
            "Translated steps \u2014 same count and order as the source, and " +
            "never numbered (the app numbers them).",
        },
        tip: {
          type: "string",
          description:
            "Translated tip. Safety wording must be preserved in full.",
        },
      },
    },
  },
];

/**
 * Translates a recipe's renderable text into [language].
 *
 * One small Haiku call, no web search. Returns null on any failure or if the
 * model changed the ingredient/step counts, so the caller can fall back to
 * English. Never throws.
 *
 * The count guard matters more here than for products: a dropped step does not
 * just desync a chip row, it silently renumbers the instructions the user is
 * meant to follow.
 */
export async function translateRecipeText(
  text: RecipeText,
  languageCode: string
): Promise<RecipeText | null> {
  const language = languageName(languageCode);
  const started = Date.now();
  try {
    const response = await withRetry("translateRecipeText", () =>
      getClient().messages.create({
        model: config.anthropic.model,
        max_tokens: 4096,
        temperature: 0,
        system: [
          {
            type: "text",
            text: generateRecipeTranslationSystemPrompt(),
            cache_control: {type: "ephemeral"},
          },
        ],
        messages: [
          {role: "user", content: [
            {
              type: "text",
              text: generateRecipeTranslationUserPrompt(text, language),
            },
          ]},
        ],
        tools: RECIPE_TRANSLATION_TOOLS,
        tool_choice: {type: "tool", name: "submit_recipe_translation"},
      })
    );

    const submit = findToolUse(response.content, "submit_recipe_translation");
    const out = submit?.input;
    if (!out) return null;

    const rawIngredients =
      Array.isArray(out.ingredients) ? out.ingredients : [];
    const ingredients: RecipeIngredient[] = rawIngredients.map(
      (item: unknown, i: number) => {
        const obj = (item ?? {}) as Record<string, unknown>;
        const source = text.ingredients[i];
        return {
          name: typeof obj.name === "string" ? obj.name : source?.name ?? "",
          quantity:
            typeof obj.quantity === "string" ?
              obj.quantity :
              source?.quantity ?? "",
        };
      }
    );
    const steps = Array.isArray(out.steps) ? out.steps.map(String) : [];

    if (
      ingredients.length !== text.ingredients.length ||
      steps.length !== text.steps.length
    ) {
      logger.warn("translateRecipeText item-count mismatch \u2014 discarding", {
        languageCode,
        expectedIngredients: text.ingredients.length,
        gotIngredients: ingredients.length,
        expectedSteps: text.steps.length,
        gotSteps: steps.length,
        structuredData: true,
      });
      return null;
    }

    logger.info("translateRecipeText complete", {
      languageCode,
      ms: Date.now() - started,
      inputTokens: response.usage?.input_tokens,
      outputTokens: response.usage?.output_tokens,
      structuredData: true,
    });

    return {
      name: typeof out.name === "string" ? out.name : text.name,
      description:
        typeof out.description === "string" ?
          out.description :
          text.description,
      ingredients,
      steps,
      tip: typeof out.tip === "string" ? out.tip : text.tip,
    };
  } catch (error) {
    logger.warn("translateRecipeText failed", {
      languageCode,
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return null;
  }
}

const BRAND_VERDICT_TOOLS: Anthropic.Tool[] = [
  {
    name: "submit_brand_verdict",
    description: "Submit the brand quality verdict.",
    input_schema: {
      type: "object",
      required: ["score", "headline", "reasons"],
      properties: {
        score: {type: "number", minimum: 0, maximum: 100},
        headline: {type: "string"},
        reasons: {
          type: "array",
          items: {type: "string"},
          minItems: 2,
          maxItems: 4,
        },
        positives: {type: "array", items: {type: "string"}, maxItems: 2},
      },
    },
  },
];

export interface BrandVerdictResult {
  score: number;
  headline: string;
  reasons: string[];
  positives: string[];
}

/**
 * Onboarding brand critique. One Haiku call, no web search; grounded by the
 * supplied catalog context (avg score + common cons) when present. Returns the
 * verdict, or null on failure so the client degrades gracefully.
 */
export async function analyzeBrand(
  input: BrandVerdictInput
): Promise<BrandVerdictResult | null> {
  if (!input?.brand) return null;
  try {
    const response = await withRetry("analyzeBrand", () =>
      getClient().messages.create({
        model: config.anthropic.model,
        max_tokens: 600,
        temperature: 0.4,
        system: [
          {
            type: "text",
            text: generateBrandVerdictSystemPrompt(),
            cache_control: {type: "ephemeral"},
          },
        ],
        messages: [
          {role: "user", content: [
            {type: "text", text: generateBrandVerdictUserPrompt(input)},
          ]},
        ],
        tools: BRAND_VERDICT_TOOLS,
        tool_choice: {type: "tool", name: "submit_brand_verdict"},
      })
    );

    const submit = findToolUse(response.content, "submit_brand_verdict");
    const out = submit?.input;
    if (out && typeof out.headline === "string" && Array.isArray(out.reasons)) {
      return {
        score: typeof out.score === "number" ?
          Math.max(0, Math.min(100, Math.round(out.score))) :
          0,
        headline: out.headline.trim(),
        reasons: out.reasons.filter((r: unknown) => typeof r === "string"),
        positives: Array.isArray(out.positives) ?
          out.positives.filter((r: unknown) => typeof r === "string") :
          [],
      };
    }
    return null;
  } catch (error) {
    logger.warn("analyzeBrand failed", {
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return null;
  }
}

/**
 * Resolves a raw product-image URL for an identified product whose cached
 * `imageUrl` is empty, via SerpAPI Google Images. Returns the first candidate
 * whose content-type validates as an image — so the caller's
 * processProductImage is very likely to host it. Returns "" when nothing
 * usable is found.
 *
 * SerpAPI-first by design: a prior Claude web_search variant produced almost no
 * usable direct image URLs (it returns page URLs, and occasionally 400'd on a
 * dangling tool_use), so SerpAPI is now the sole source.
 */
export async function findProductImageUrl(
  brand: string,
  name: string
): Promise<string> {
  if (!brand && !name) return "";

  // Timing: split the external SerpAPI fetch from the serial HEAD validation so
  // we know which part of the image-fallback cost is the third-party call vs ours.
  const serpStart = Date.now();
  const candidates = await searchProductImageUrls(brand, name);
  const serpapiMs = Date.now() - serpStart;

  const validateStart = Date.now();
  let validated = 0;
  for (const candidate of candidates) {
    validated++;
    if (await isImageUrlValid(candidate)) {
      logger.info("findProductImageUrl using SerpAPI candidate", {
        brand,
        name,
        imageUrl: candidate,
        serpapiMs,
        validateMs: Date.now() - validateStart,
        candidatesChecked: validated,
        structuredData: true,
      });
      return candidate;
    }
  }

  logger.info("findProductImageUrl found no image", {
    brand,
    name,
    serpapiMs,
    validateMs: Date.now() - validateStart,
    candidatesChecked: validated,
    structuredData: true,
  });
  return "";
}

/**
 * Optional verification step for the Algolia search-by-name path. When the
 * fuzzy string match is ambiguous, ask Haiku to pick the matching candidate
 * (or "none") from the expected product description. Costs ~$0.0001 and
 * ~600ms per call but eliminates string-match false negatives like
 * "Royal Canin Kitten" vs "Royal Canin Junior" (semantic equivalence).
 *
 * Returns the matched candidate, or null if Haiku says "none of these".
 */
export async function verifyMatchWithLLM(
  expected: ProductIdentification,
  candidates: Product[]
): Promise<Product | null> {
  if (candidates.length === 0) return null;

  const candidateLines = candidates
    .map((c, i) => `${i}. brand="${c.brand}" name="${c.name}" foodType="${c.foodType}"`)
    .join("\n");

  const prompt =
    "A user scanned a cat food product identified as:\n" +
    `  brand="${expected.brand}" name="${expected.name}" foodType="${expected.foodType}"\n\n` +
    "Here are the closest cached candidates:\n" +
    `${candidateLines}\n\n` +
    "Pick the index of the candidate that is the SAME product (same brand, " +
    "same line/variant/flavor, same food type). If none of them is the same " +
    "product, pass -1. Differences in packaging size or pack count are fine; " +
    "differences in life stage (kitten vs adult), flavor, or formulation are not. " +
    "Breed- or condition-specific variants (e.g. \"Persian\", \"Maine Coon\", " +
    "\"British Shorthair\", \"Sterilised\") are DIFFERENT products from the " +
    "generic line — only pick one if the scanned name also names that breed or " +
    "condition. If the scan is the plain/generic product, prefer the generic " +
    "candidate over any breed- or condition-specific variant.";

  const tools: Anthropic.Tool[] = [
    {
      name: "submit_match",
      description:
        "Report which candidate (if any) is the same product as the scan",
      input_schema: {
        type: "object",
        required: ["matchIndex"],
        properties: {
          matchIndex: {
            type: "integer",
            minimum: -1,
            maximum: candidates.length - 1,
            description: "0-based index of the matching candidate, or -1 for none",
          },
        },
      },
    },
  ];

  try {
    const response = await withRetry("verifyMatchWithLLM", () =>
      getClient().messages.create({
        model: config.anthropic.model,
        max_tokens: 128,
        temperature: 0,
        messages: [{role: "user", content: [{type: "text", text: prompt}]}],
        tools,
        tool_choice: {type: "any"},
      })
    );

    const submit = findToolUse(response.content, "submit_match");
    const idx = submit?.input?.matchIndex;
    if (typeof idx !== "number" || idx < 0 || idx >= candidates.length) {
      logger.info("LLM verifier rejected all candidates", {
        expectedBrand: expected.brand,
        expectedName: expected.name,
        candidateCount: candidates.length,
        structuredData: true,
      });
      return null;
    }

    const winner = candidates[idx];
    logger.info("LLM verifier selected candidate", {
      expectedBrand: expected.brand,
      expectedName: expected.name,
      pickedBrand: winner.brand,
      pickedName: winner.name,
      pickedIndex: idx,
      structuredData: true,
    });
    return winner;
  } catch (error) {
    logger.warn("LLM verifier failed - skipping verification", {
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return null;
  }
}

/**
 * Litter counterpart to {@link verifyMatchWithLLM}. Kept separate rather than
 * generalized because the sameness criteria differ: for litter, scented vs
 * unscented and clumping vs non-clumping are DIFFERENT products even within one
 * line, while pack size is still irrelevant.
 *
 * Returns the matched candidate, or null if Haiku says "none of these".
 */
export async function verifyLitterMatchWithLLM(
  expected: LitterIdentification,
  candidates: Litter[]
): Promise<Litter | null> {
  if (candidates.length === 0) return null;

  const candidateLines = candidates
    .map((c, i) => `${i}. brand="${c.brand}" name="${c.name}"`)
    .join("\n");

  const prompt =
    "A user scanned a cat litter identified as:\n" +
    `  brand="${expected.brand}" name="${expected.name}"\n\n` +
    "Here are the closest cached candidates:\n" +
    `${candidateLines}\n\n` +
    "Pick the index of the candidate that is the SAME product (same brand, " +
    "same line and variant). If none is the same product, pass -1. " +
    "Differences in pack size or weight are fine. Differences in scent " +
    "(scented vs unscented vs a named fragrance), in clumping behaviour, or " +
    "in substrate are NOT the same product — only pick a variant if the " +
    "scanned name names that same variant.";

  const tools: Anthropic.Tool[] = [
    {
      name: "submit_match",
      description:
        "Report which candidate (if any) is the same litter as the scan",
      input_schema: {
        type: "object",
        required: ["matchIndex"],
        properties: {
          matchIndex: {
            type: "integer",
            minimum: -1,
            maximum: candidates.length - 1,
            description: "0-based index of the matching candidate, or -1 for none",
          },
        },
      },
    },
  ];

  try {
    const response = await withRetry("verifyLitterMatchWithLLM", () =>
      getClient().messages.create({
        model: config.anthropic.model,
        max_tokens: 128,
        temperature: 0,
        messages: [{role: "user", content: [{type: "text", text: prompt}]}],
        tools,
        tool_choice: {type: "any"},
      })
    );

    const submit = findToolUse(response.content, "submit_match");
    const idx = submit?.input?.matchIndex;
    if (typeof idx !== "number" || idx < 0 || idx >= candidates.length) {
      logger.info("LLM verifier rejected all litter candidates", {
        expectedBrand: expected.brand,
        expectedName: expected.name,
        candidateCount: candidates.length,
        structuredData: true,
      });
      return null;
    }

    const winner = candidates[idx];
    logger.info("LLM verifier selected litter candidate", {
      expectedBrand: expected.brand,
      expectedName: expected.name,
      matchedName: winner.name,
      structuredData: true,
    });
    return winner;
  } catch (error) {
    logger.warn("LLM litter match verification failed", {
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return null;
  }
}

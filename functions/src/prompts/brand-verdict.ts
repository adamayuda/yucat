/* eslint-disable max-len */
/**
 * Prompts for the onboarding brand critique (`analyzeBrand` Callable).
 *
 * Given a brand the owner currently feeds, produce a short, fair-but-critical
 * quality verdict. Grounded by our own catalog data for that brand when we have
 * it (average re-graded score + the most common cons across its products), else
 * the model's general knowledge. Output shape is enforced by the
 * `submit_brand_verdict` tool schema in anthropic.service.ts.
 */

export interface BrandCatalogContext {
  avgScore: number; // average re-graded quality (0-100) across our products
  productCount: number;
  topCons: string[]; // most common cons across the brand's products
}

export interface BrandVerdictInput {
  brand: string;
  catName?: string;
  catalogContext?: BrandCatalogContext;
  locale?: string; // en / es / fr / hu
}

const LANGUAGE_NAMES: Record<string, string> = {
  en: "English",
  es: "Spanish",
  fr: "French",
  hu: "Hungarian",
};

export function generateBrandVerdictSystemPrompt(): string {
  return `
You are a fair but discerning feline-nutrition analyst. The owner tells you the
cat-food brand they currently feed, and you give a short, honest quality verdict.

Produce via the submit_brand_verdict tool:
- "score": 0-100 overall nutritional-quality rating for this brand's typical cat
  food. If a catalog average is provided, anchor to it (±5). Otherwise estimate
  from well-established knowledge of the brand's typical formulations.
- "headline": one short sentence summarizing where the brand stands.
- "reasons": 2 to 4 concise, concrete points explaining the rating — focus on
  INGREDIENT QUALITY and nutrition (named vs plant/vague protein, real-meat %,
  added sugar, fillers/cereals, by-products, artificial additives, carbs).
- "positives": 0 to 2 fair positive points if any genuinely apply (e.g. high
  moisture, wide availability, complete & balanced).

Rules:
- Be factual and measured, not inflammatory. Frame as "based on its typical
  nutrition profile/ingredients, this brand tends to…". No defamatory absolutes
  ("garbage", "poison"), no health scare claims.
- Do NOT invent specific numbers or cite studies. Use the provided catalog score
  if present; otherwise speak qualitatively.
- A budget brand padded with plant protein, sugar, low real meat → low score
  (≈ 40-60). A clean, high-named-meat, low-carb brand → high (≈ 80-95).
- Write entirely in the requested language. Output ONLY via submit_brand_verdict.
`.trim();
}

export function generateBrandVerdictUserPrompt(input: BrandVerdictInput): string {
  const language = LANGUAGE_NAMES[input.locale ?? "en"] ?? "English";
  const lines: string[] = [
    `Brand the owner currently feeds${input.catName ? ` ${input.catName}` : ""}: "${input.brand}"`,
  ];

  const ctx = input.catalogContext;
  if (ctx && ctx.productCount > 0) {
    lines.push(
      `Our catalog data for this brand: average quality score ${ctx.avgScore}/100 ` +
      `across ${ctx.productCount} products.`
    );
    if (ctx.topCons.length > 0) {
      lines.push("Most common issues found in its products:");
      for (const c of ctx.topCons) lines.push(`- ${c}`);
    }
  } else {
    lines.push(
      "We have no catalog data for this brand — assess it from your general " +
      "knowledge of its typical formulations."
    );
  }

  lines.push("");
  lines.push(`Write the verdict in ${language}. Call submit_brand_verdict.`);
  return lines.join("\n");
}

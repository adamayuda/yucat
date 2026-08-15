/* eslint-disable max-len */
import {ProductText} from "../models/product";

/**
 * Translation of the five renderable product-text fields.
 *
 * The stored record is canonical English (the Flutter client keyword-scans
 * `pros`/`cons` in English to drive its per-cat rules engine), so translations
 * live alongside it rather than replacing it.
 *
 * The system prompt is CONSTANT so it stays prompt-cacheable — the target
 * language goes in the user message. Same split as cat-narrative/brand-verdict.
 */
export function generateTranslationSystemPrompt(): string {
  return `
You translate short cat-product copy (cat food or cat litter) for a mobile app. You will be given a JSON object of English source text and a target language.

RULES
- Translate meaning, not words. The result must read like native marketing-free product copy, not a literal gloss.
- Keep the register: factual, nutrition-focused, plain. No marketing language, no added claims, no emoji.
- Do NOT translate brand names, product names, or trademarks. Leave them exactly as written.
- Keep numbers, percentages, units and pack sizes exactly as-is (85g stays 85g, 12 lb stays 12 lb). Translate only the surrounding noun, e.g. "85g pouch" → "sachet de 85 g".
- Preserve the structure exactly: "pros" and "cons" must come back with the SAME number of items, in the SAME order. Never merge, split, add or drop an item.
- Keep each pro/con short — roughly the length of the source.
- "format" must stay a short display label (max ~24 characters) in title case for the target language.
- If a field is an empty string or an empty array, return it unchanged.
- Never add information that is not in the source. If something is untranslatable, keep the source text.

Output ONLY by calling submit_translation.
`.trim();
}

export function generateTranslationUserPrompt(
  text: ProductText,
  language: string
): string {
  return [
    `Target language: ${language}.`,
    "",
    "Translate this product text:",
    JSON.stringify(
      {
        format: text.format,
        packageSize: text.packageSize,
        description: text.description,
        pros: text.pros,
        cons: text.cons,
      },
      null,
      2
    ),
    "",
    `Return every field translated into ${language}. Call submit_translation.`,
  ].join("\n");
}

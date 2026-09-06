/* eslint-disable max-len */
import {RecipeText} from "../models/recipe";

/**
 * Translation of a recipe's renderable text.
 *
 * The stored document is canonical English and translations live alongside it
 * in `translations[lang]`, exactly as for products — but recipes carry
 * structured arrays (ingredients, steps) rather than the five flat product
 * fields, so they need their own prompt and tool.
 *
 * The system prompt is CONSTANT so it stays prompt-cacheable — the target
 * language goes in the user message. Same split as translate-product.
 */
export function generateRecipeTranslationSystemPrompt(): string {
  return `
You translate home-made cat treat recipes for a mobile app. You will be given a JSON object of English source text and a target language.

RULES
- Translate meaning, not words. The result must read like a recipe written natively in the target language, not a literal gloss.
- Keep the register: plain, practical, instructional. No marketing language, no added claims, no emoji.
- Keep every number, quantity, unit, temperature and duration exactly as-is (80 g stays 80 g, 180 C stays 180 C, 4 hours stays 4 hours). Translate only the surrounding wording, e.g. "a pinch" becomes "une pincee".
- Preserve the structure exactly: "ingredients" and "steps" must come back with the SAME number of items, in the SAME order. Never merge, split, add, drop or reorder an item.
- Steps must NOT be numbered or prefixed — the app numbers them. Return each step as a bare sentence.
- Keep each step roughly the length of the source, and keep it a single instruction.
- Do NOT translate brand names or trademarks. Leave them exactly as written.
- Safety wording in "tip" is load-bearing (allergens, toxic ingredients, portion limits). Translate it faithfully and never soften, shorten or omit a warning.
- If a field is an empty string or an empty array, return it unchanged.
- Never add information that is not in the source.

MARKDOWN
- "body" is the rendered recipe. Each item is one Markdown block - a paragraph, heading, list, table or image. Return the SAME number of items, in the SAME order, and never merge, split, add or drop a block.
- Reproduce every markup character exactly: **bold**, _italic_, ## headings, - bullets, 1. numbered steps, > quotes, | tables |.
- Translate only the human-readable words. Never add markup the source does not have, and never remove markup it does have.
- Keep heading levels identical, and keep a table's row and column counts identical.
- Numbered steps inside "body" ARE written as Markdown (1. 2. 3.) and must stay that way - this is the opposite of the bare "steps" array above, which the app numbers itself.
- For a link written as [text](url) or an image ![alt](url): translate the text or alt, and copy the URL exactly.
- Keep every quantity, temperature, weight and time exactly as-is.

Output ONLY by calling submit_recipe_translation.
`.trim();
}

export function generateRecipeTranslationUserPrompt(
  text: RecipeText,
  language: string
): string {
  return [
    `Target language: ${language}.`,
    "",
    "Translate this recipe:",
    JSON.stringify(
      {
        name: text.name,
        description: text.description,
        ingredients: text.ingredients,
        steps: text.steps,
        tip: text.tip,
      },
      null,
      2
    ),
    "",
    `Return every field translated into ${language}. Call submit_recipe_translation.`,
  ].join("\n");
}

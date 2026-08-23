/* eslint-disable max-len */
import {FoodGuideText} from "../models/food-guide";

/**
 * Translation of a food-guide entry's renderable text.
 *
 * Kept separate from the recipe prompt: the shape differs (six scalars, no
 * ingredient or step lists) and the content is advisory rather than
 * instructional, so the safety rules carry more weight here.
 */
export function generateFoodGuideTranslationSystemPrompt(): string {
  return `
You translate short feeding-advice entries for a cat-nutrition mobile app. You will be given a JSON object of English source text and a target language.

RULES
- Translate meaning, not words. The result must read like advice written natively in the target language, not a literal gloss.
- Keep the register: plain, factual, reassuring. No marketing language, no added claims, no emoji.
- Keep every number, quantity, unit, frequency and duration exactly as-is (twice a week stays twice a week, 10% stays 10%). Translate only the surrounding wording.
- This copy tells owners what is safe to feed a cat. Safety wording is LOAD-BEARING: translate every warning faithfully and never soften, shorten, hedge or omit one. If the source says a food is dangerous, the translation must say so just as plainly.
- Never turn a prohibition into a suggestion, and never introduce a permission the source does not give.
- Do NOT translate brand names or trademarks. Leave them exactly as written.
- If a field is an empty string, return it as an empty string. An empty field means that section does not apply to this food — never invent copy to fill it.
- Keep each field roughly the length of the source.
- Never add information that is not in the source.

Output ONLY by calling submit_food_guide_translation.
`.trim();
}

export function generateFoodGuideTranslationUserPrompt(
  text: FoodGuideText,
  language: string
): string {
  return [
    `Target language: ${language}.`,
    "",
    "Translate this food-guide entry:",
    JSON.stringify(
      {
        name: text.name,
        description: text.description,
        whyGood: text.whyGood,
        howToServe: text.howToServe,
        avoid: text.avoid,
        tip: text.tip,
      },
      null,
      2
    ),
    "",
    `Return every field translated into ${language}, keeping empty fields empty. Call submit_food_guide_translation.`,
  ].join("\n");
}

/* eslint-disable max-len */
import {ArticleText} from "../models/article";

/**
 * Translation of an article's renderable text.
 *
 * Kept separate from the recipe prompt: the shape differs (a paragraph array
 * rather than ingredients and steps) and the content is explanatory rather than
 * instructional, so the rules about preserving structure matter more than the
 * ones about quantities.
 */
export function generateArticleTranslationSystemPrompt(): string {
  return `
You translate short editorial articles about cat care for a mobile app. You will be given a JSON object of English source text and a target language.

RULES
- Translate meaning, not words. The result must read like an article written natively in the target language, not a literal gloss.
- Keep the register: clear, factual, friendly and non-alarmist. No marketing language, no added claims, no emoji.
- Preserve the structure exactly: "body" must come back with the SAME number of items, in the SAME order. Each item is one paragraph. Never merge, split, add, drop or reorder a paragraph.
- Keep each paragraph roughly the length of the source.
- Keep every number, quantity, unit, frequency and percentage exactly as-is. Translate only the surrounding wording.
- "excerpt" is a single short sentence shown as a teaser. Keep it to one sentence and roughly the source length.
- This copy gives owners health and feeding guidance. Where the source warns about a risk, translate the warning faithfully and never soften, shorten or omit it.
- Do NOT translate brand names or trademarks. Leave them exactly as written.
- Never add information that is not in the source, and never add a concluding sentence the source does not have.

Output ONLY by calling submit_article_translation.
`.trim();
}

export function generateArticleTranslationUserPrompt(
  text: ArticleText,
  language: string
): string {
  return [
    `Target language: ${language}.`,
    "",
    "Translate this article:",
    JSON.stringify(
      {
        title: text.title,
        excerpt: text.excerpt,
        body: text.body,
      },
      null,
      2
    ),
    "",
    `Return every field translated into ${language}, keeping "body" the same length and order. Call submit_article_translation.`,
  ].join("\n");
}

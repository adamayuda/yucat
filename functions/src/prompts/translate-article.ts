/* eslint-disable max-len */
import {ArticleText} from "../models/article";

/**
 * Translation of an article's renderable text.
 *
 * Kept separate from the recipe prompt: the shape differs (a block array rather
 * than ingredients and steps) and the content is explanatory rather than
 * instructional, so the rules about preserving structure matter more than the
 * ones about quantities.
 *
 * WARNING: "body" items are **Markdown**, rendered client-side by
 * `DSMarkdownBlock`. The MARKDOWN rules below are load-bearing, not cosmetic.
 * The seeder's structural checks are an item count plus the per-item markup
 * signature in `markupSignature` (anthropic.service.ts) — nothing else looks at
 * this text again. Loosening these rules re-opens a silent-content-loss path on
 * health-advice copy.
 */
export function generateArticleTranslationSystemPrompt(): string {
  return `
You translate short editorial articles about cat care for a mobile app. You will be given a JSON object of English source text and a target language.

RULES
- Translate meaning, not words. The result must read like an article written natively in the target language, not a literal gloss.
- Keep the register: clear, factual, friendly and non-alarmist. No marketing language, no added claims, no emoji.
- Preserve the structure exactly: "body" must come back with the SAME number of items, in the SAME order. Each item is one Markdown block - a paragraph, a heading, or a list. Never merge, split, add, drop or reorder a block.
- Keep each block roughly the length of the source.
- Keep every number, quantity, unit, frequency and percentage exactly as-is. Translate only the surrounding wording.
- "excerpt" is a single short sentence shown as a teaser. Keep it to one sentence and roughly the source length.
- This copy gives owners health and feeding guidance. Where the source warns about a risk, translate the warning faithfully and never soften, shorten or omit it.
- Do NOT translate brand names or trademarks. Leave them exactly as written.
- Never add information that is not in the source, and never add a concluding sentence the source does not have.

MARKDOWN
- Every "body" item is Markdown. Reproduce its markup character for character: **bold**, _italic_, ## headings, - bullets, 1. numbered items, > quotes.
- Translate only the human-readable words. Never add markup the source does not have, and never remove markup it does have.
- Keep heading levels identical. A ## stays ##; never promote or demote it.
- A block containing a list must come back with the SAME number of list items, each on its own line with the same marker.
- For a link written as [text](url): translate the text, and copy the URL exactly. Never translate, shorten, localise or re-point a URL.
- Do not wrap, re-indent, or add blank lines inside a block.

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
    `Return every field translated into ${language}, keeping "body" the same length and order and every Markdown marker intact. Call submit_article_translation.`,
  ].join("\n");
}

export type ArticleCategory =
  | "nutrition"
  | "health"
  | "behaviour"
  | "other";

/** Runtime list, so tool schemas and validation can't drift from the type. */
export const ARTICLE_CATEGORIES: ArticleCategory[] = [
  "nutrition",
  "health",
  "behaviour",
  "other",
];

/**
 * The translatable half of an article.
 *
 * `body` is an ARRAY, one entry per **Markdown block** (a paragraph, heading,
 * list, table or image) — so unlike `FoodGuideText` this needs the item-count
 * guard `RecipeText` has, plus the per-block `markupSignature` guard, because
 * the count check is blind to structure *inside* a block. Dropped content would
 * silently delete advice the reader never learns was missing.
 */
export interface ArticleText {
  title: string;
  excerpt: string;
  body: string[];
}

export interface Article {
  /** Document id — an authored slug, e.g. "why-cats-drink-little". */
  id: string;

  // Shared, never translated.
  category: ArticleCategory;
  /** Authored reading time in minutes, not derived from word count. */
  readMinutes: number;
  imageUrl: string | null;
  published: boolean;
  /** Manual sort key. The FIRST published article is what Home features. */
  order: number;

  // Canonical English, flat — same contract as Recipe/FoodGuide/Product.
  title: string;
  /**
   * One short, complete sentence for the Home card. Deliberately its own field
   * rather than a clipped `body[0]`, which would cut mid-sentence.
   */
  excerpt: string;
  /** Markdown blocks. Authored in `scripts/data/*.md`, converted at seed time. */
  body: string[];

  /**
   * Every other language. **No "en" key** — English is the flat fields above.
   */
  translations?: Record<string, ArticleText>;

  /**
   * SHA-1 of the canonical text. The seeder re-translates only when this
   * changes, which keeps translations from going silently stale after an
   * English edit.
   */
  translationsSourceHash?: string;
}

/**
 * The canonical (English) translatable text of an article.
 *
 * ⚠️ The seeder hashes `JSON.stringify` of this object, so **key order is part
 * of the hash**. Reordering these fields invalidates every stored hash and
 * forces a full re-translation.
 */
export function canonicalArticleText(article: Article): ArticleText {
  return {
    title: article.title,
    excerpt: article.excerpt,
    body: article.body,
  };
}

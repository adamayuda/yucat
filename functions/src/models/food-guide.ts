export type FoodSafety = "safe" | "caution" | "unsafe";

/** Runtime list, so tool schemas and validation can't drift from the type. */
export const FOOD_SAFETIES: FoodSafety[] = ["safe", "caution", "unsafe"];

/**
 * The translatable half of a food-guide entry.
 *
 * Every field is a plain string — unlike `RecipeText` there are no arrays, so
 * the translation path needs no item-count guard.
 *
 * An EMPTY STRING is meaningful: it means "this row does not apply". A
 * dangerous food has no `whyGood` and no `howToServe`, and the client renders
 * only the rows that carry copy.
 */
export interface FoodGuideText {
  name: string;
  description: string;
  whyGood: string;
  howToServe: string;
  avoid: string;
  tip: string;
}

export interface FoodGuideItem {
  /** Document id — an authored slug, e.g. "fish", "dangerous-foods". */
  id: string;

  // Shared, never translated.
  /** The glyph the Home lane tile renders. */
  emoji: string;
  safety: FoodSafety;
  imageUrl: string | null;
  published: boolean;
  /** Manual sort key for the Home lane. */
  order: number;

  // Canonical English, flat — same contract as Recipe/Product/Litter.
  name: string;
  description: string;
  whyGood: string;
  howToServe: string;
  avoid: string;
  tip: string;

  /**
   * Every other language. **No "en" key** — English is the flat fields above.
   */
  translations?: Record<string, FoodGuideText>;

  /**
   * SHA-1 of the canonical text. The seeder re-translates only when this
   * changes, which keeps translations from going silently stale after an
   * English edit.
   */
  translationsSourceHash?: string;
}

/**
 * The canonical (English) translatable text of a food-guide entry.
 *
 * ⚠️ The seeder hashes `JSON.stringify` of this object, so **key order is part
 * of the hash**. Reordering these fields invalidates every stored hash and
 * forces a full re-translation.
 */
export function canonicalFoodGuideText(item: FoodGuideItem): FoodGuideText {
  return {
    name: item.name,
    description: item.description,
    whyGood: item.whyGood,
    howToServe: item.howToServe,
    avoid: item.avoid,
    tip: item.tip,
  };
}

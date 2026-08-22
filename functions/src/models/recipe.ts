/**
 * Home-made cat treat recipes.
 *
 * Unlike products and litter, recipes are a **curated catalogue** authored
 * ahead of time rather than an unknown the server meets at scan time. There is
 * no runtime analysis and no lazy translation: `scripts/seed-recipes.ts` writes
 * every language into the Firestore document in one pass.
 *
 * The wire strings below MUST match the Dart enums in
 * `lib/features/recipes/domain/entities/recipe_entity.dart` — the client parses
 * them with a lenient `fromWire` that degrades rather than throws, so a drift
 * here shows up as silently wrong categories, not as an error.
 */

export type RecipeCategory =
  | "biscuits"
  | "cakes"
  | "frozen"
  | "meals"
  | "other";

export type RecipeDifficulty = "easy" | "medium" | "hard";

export type RecipeCompatibility =
  | "compatible"
  | "caution"
  | "incompatible";

/** Runtime lists, so tool schemas and validation can't drift from the types. */
export const RECIPE_CATEGORIES: RecipeCategory[] = [
  "biscuits",
  "cakes",
  "frozen",
  "meals",
  "other",
];
export const RECIPE_DIFFICULTIES: RecipeDifficulty[] = [
  "easy",
  "medium",
  "hard",
];
export const RECIPE_COMPATIBILITIES: RecipeCompatibility[] = [
  "compatible",
  "caution",
  "incompatible",
];

export interface RecipeIngredient {
  name: string;
  /**
   * A display phrase ("80 g", "1 tbsp", "a pinch"), not an amount plus a unit —
   * translators keep the number and unit and translate only the wording.
   */
  quantity: string;
}

/**
 * The translatable half of a recipe.
 *
 * Mirrors `ProductText`'s role but not its shape, which is why recipes need
 * their own translate call rather than reusing `translateProductText`.
 */
export interface RecipeText {
  name: string;
  description: string;
  ingredients: RecipeIngredient[];
  steps: string[];
  tip: string;
}

export interface Recipe {
  /** Document id — an authored slug, e.g. "frozen-pate-bites". */
  id: string;

  // Shared, never translated.
  category: RecipeCategory;
  prepMinutes: number;
  requiresFreezing: boolean;
  difficulty: RecipeDifficulty;
  compatibility: RecipeCompatibility;
  imageUrl: string | null;
  published: boolean;
  /** Manual sort key for the list screen. */
  order: number;

  // Canonical English, flat — same contract as Product/Litter.
  name: string;
  description: string;
  ingredients: RecipeIngredient[];
  steps: string[];
  tip: string;

  /**
   * Every other language. **No "en" key** — English is the flat fields above.
   */
  translations?: Record<string, RecipeText>;

  /**
   * SHA-1 of the canonical text. The seeder re-translates only when this
   * changes, which is what keeps translations from going silently stale after
   * an English edit — a gap the product path has.
   */
  translationsSourceHash?: string;
}

/** The canonical (English) translatable text of a recipe. */
export function canonicalRecipeText(recipe: Recipe): RecipeText {
  return {
    name: recipe.name,
    description: recipe.description,
    ingredients: recipe.ingredients,
    steps: recipe.steps,
    tip: recipe.tip,
  };
}

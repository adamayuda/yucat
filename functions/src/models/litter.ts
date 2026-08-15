/**
 * Cat litter — the second scannable product category.
 *
 * Deliberately parallel to `models/product.ts` (same cache/self-heal/translation
 * machinery applies) but with an attribute set instead of a guaranteed analysis:
 * litter has no macros, so quality is judged on substrate, clumping, dust,
 * fragrance, tracking and odour control.
 */

/** The substrate the litter is made from — the single biggest quality driver. */
export type LitterMaterial =
  | "clay-bentonite"
  | "clay-non-clumping"
  | "silica-crystal"
  | "corn"
  | "wheat"
  | "tofu"
  | "paper"
  | "wood"
  | "walnut"
  | "grass"
  | "mixed"
  | "other";

export const LITTER_MATERIALS: LitterMaterial[] = [
  "clay-bentonite",
  "clay-non-clumping",
  "silica-crystal",
  "corn",
  "wheat",
  "tofu",
  "paper",
  "wood",
  "walnut",
  "grass",
  "mixed",
  "other",
];

/**
 * Three-state facts. `unknown` is a first-class value on purpose: most of these
 * are not printed on every package, and the app renders a chip only for the
 * ones we actually know. Guessing would be worse than staying silent.
 */
export type LitterLevel = "low" | "moderate" | "high" | "unknown";
export const LITTER_LEVELS: LitterLevel[] = [
  "low", "moderate", "high", "unknown",
];

export type Tristate = "yes" | "no" | "unknown";
export const TRISTATES: Tristate[] = ["yes", "no", "unknown"];

/**
 * The five human-readable fields the app renders, in one language.
 *
 * Intentionally the same shape as `ProductText` so `translateProductText` and
 * the lazy-translation cache work unchanged for both categories.
 */
export interface LitterText {
  format: string;
  packageSize: string;
  description: string;
  pros: string[];
  cons: string[];
}

export interface Litter {
  /** Algolia objectID — `lit-{brand}-{name}`, text-derived like the food cache. */
  id: string;
  name: string;
  brand: string;

  material: LitterMaterial;
  clumping: Tristate;
  /** Airborne dust. The attribute that matters most for respiratory health. */
  dustLevel: LitterLevel;
  /** Added fragrance. Unscented is preferred by most cats. */
  scented: Tristate;
  trackingLevel: LitterLevel;
  odorControl: LitterLevel;
  flushable: Tristate;
  biodegradable: Tristate;
  /** e.g. "Baking soda", "Activated charcoal", "Fragrance". Empty when unknown. */
  additives: string[];

  /** Short display string, e.g. "Clumping bentonite clay". */
  format: string;
  packageSize: string;
  description: string;
  pros: string[];
  cons: string[];

  imageUrl: string;
  /**
   * 0-100 universal quality score. **0 is a sentinel meaning "no data found"**,
   * not a grade — same contract as `Product.score`, and the same predicate
   * (`score > 0`) drives the self-healing cache.
   */
  score: number;
  version: string;

  isAiIdentified?: boolean;
  /** Epoch ms of the last self-heal attempt; separate stamps, as for products. */
  lastAnalysisAttempt?: number;
  lastImageAttempt?: number;
  /**
   * Cached translations of the five renderable text fields, keyed by language
   * code. The flat fields stay canonical English — no "en" entry.
   */
  translations?: Record<string, LitterText>;
}

export class LitterModel implements Litter {
  id: string;
  name: string;
  brand: string;
  material: LitterMaterial;
  clumping: Tristate;
  dustLevel: LitterLevel;
  scented: Tristate;
  trackingLevel: LitterLevel;
  odorControl: LitterLevel;
  flushable: Tristate;
  biodegradable: Tristate;
  additives: string[];
  format: string;
  packageSize: string;
  description: string;
  pros: string[];
  cons: string[];
  imageUrl: string;
  score: number;
  version: string;
  isAiIdentified: boolean;
  lastAnalysisAttempt?: number;
  lastImageAttempt?: number;
  translations?: Record<string, LitterText>;

  constructor(data: Partial<Litter>) {
    this.id = data.id || "";
    this.name = data.name || "";
    this.brand = data.brand || "";
    this.material = data.material || "other";
    this.clumping = data.clumping || "unknown";
    this.dustLevel = data.dustLevel || "unknown";
    this.scented = data.scented || "unknown";
    this.trackingLevel = data.trackingLevel || "unknown";
    this.odorControl = data.odorControl || "unknown";
    this.flushable = data.flushable || "unknown";
    this.biodegradable = data.biodegradable || "unknown";
    this.additives = data.additives || [];
    this.format = data.format || "";
    this.packageSize = data.packageSize || "";
    this.description = data.description || "";
    this.pros = data.pros || [];
    this.cons = data.cons || [];
    this.imageUrl = data.imageUrl || "";
    this.score = data.score || 0;
    this.version = data.version || "v1";
    this.isAiIdentified = data.isAiIdentified ?? false;
    this.lastAnalysisAttempt = data.lastAnalysisAttempt;
    this.lastImageAttempt = data.lastImageAttempt;
    this.translations = data.translations;
  }

  static fromObject(data: Partial<Litter>): LitterModel {
    return new LitterModel(data);
  }

  toObject(): Litter {
    return {
      id: this.id,
      name: this.name,
      brand: this.brand,
      material: this.material,
      clumping: this.clumping,
      dustLevel: this.dustLevel,
      scented: this.scented,
      trackingLevel: this.trackingLevel,
      odorControl: this.odorControl,
      flushable: this.flushable,
      biodegradable: this.biodegradable,
      additives: this.additives,
      format: this.format,
      packageSize: this.packageSize,
      description: this.description,
      pros: this.pros,
      cons: this.cons,
      imageUrl: this.imageUrl,
      score: this.score,
      version: this.version,
      isAiIdentified: this.isAiIdentified,
      lastAnalysisAttempt: this.lastAnalysisAttempt,
      lastImageAttempt: this.lastImageAttempt,
      translations: this.translations,
    };
  }
}

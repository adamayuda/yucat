export type FoodType = "wet" | "dry" | "treat" | "topper" | "supplement";

/**
 * The five human-readable fields the app renders, in one language.
 *
 * `name`/`brand` are deliberately excluded — they are transcribed off the
 * packaging (see prompts/identify-product) and must never be translated.
 * `ingredients` is excluded because the app never renders it.
 */
export interface ProductText {
  format: string;
  packageSize: string;
  description: string;
  pros: string[];
  cons: string[];
}

export interface Product {
  barcode: string;
  name: string;
  brand: string;
  foodType: FoodType;
  protein: number;
  fat: number;
  moisture: number;
  carbs: number;
  fiber: number;
  ash: number;
  imageUrl: string;
  score: number;
  pros: string[];
  cons: string[];
  version: string;
  // Added in V2 — optional so cached pre-V2 rows still round-trip cleanly.
  isAiIdentified?: boolean;
  format?: string;
  packageSize?: string;
  description?: string;
  // Ingredients list as printed on the label, in order. Empty array when not
  // found. Optional so pre-existing rows round-trip cleanly.
  ingredients?: string[];
  // Epoch ms of the last self-heal attempt. Separate stamps so an entry with
  // nutrition but no image can retry the image without a full re-analysis (and
  // vice-versa). Absent on pre-existing rows → treated as "never attempted".
  lastAnalysisAttempt?: number;
  lastImageAttempt?: number;
  // Cached translations of the five renderable text fields, keyed by language
  // code. The flat fields above stay canonical English — the Flutter client's
  // per-cat rules engine keyword-scans them, so they must not be localized in
  // place. Filled lazily: the first request for a language pays one small Haiku
  // call, everyone after reads it from here. No "en" entry (that's the flat
  // fields). Absent on pre-existing rows.
  translations?: Record<string, ProductText>;
}

export class ProductModel implements Product {
  barcode: string;
  name: string;
  brand: string;
  foodType: FoodType;
  protein: number;
  fat: number;
  moisture: number;
  carbs: number;
  fiber: number;
  ash: number;
  imageUrl: string;
  score: number;
  pros: string[];
  cons: string[];
  version: string;
  isAiIdentified: boolean;
  format: string;
  packageSize: string;
  description: string;
  ingredients: string[];
  lastAnalysisAttempt?: number;
  lastImageAttempt?: number;
  translations?: Record<string, ProductText>;

  constructor(
    barcode: string,
    name: string,
    brand: string,
    foodType: FoodType,
    protein: number,
    fat: number,
    moisture: number,
    carbs: number,
    fiber: number,
    ash: number,
    imageUrl: string,
    score: number,
    pros: string[],
    cons: string[],
    version = "v2",
    isAiIdentified = false,
    format = "",
    packageSize = "",
    description = "",
    ingredients: string[] = [],
    lastAnalysisAttempt?: number,
    lastImageAttempt?: number,
    translations?: Record<string, ProductText>
  ) {
    this.barcode = barcode;
    this.name = name;
    this.brand = brand;
    this.foodType = foodType;
    this.protein = protein;
    this.fat = fat;
    this.moisture = moisture;
    this.carbs = carbs;
    this.fiber = fiber;
    this.ash = ash;
    this.imageUrl = imageUrl;
    this.score = score;
    this.pros = pros;
    this.cons = cons;
    this.version = version;
    this.isAiIdentified = isAiIdentified;
    this.format = format;
    this.packageSize = packageSize;
    this.description = description;
    this.ingredients = ingredients;
    this.lastAnalysisAttempt = lastAnalysisAttempt;
    this.lastImageAttempt = lastImageAttempt;
    this.translations = translations;
  }

  static fromObject(data: Partial<Product>): ProductModel {
    return new ProductModel(
      data.barcode || "",
      data.name || "",
      data.brand || "",
      data.foodType || "dry",
      data.protein || 0,
      data.fat || 0,
      data.moisture || 0,
      data.carbs || 0,
      data.fiber || 0,
      data.ash || 0,
      data.imageUrl || "",
      data.score || 0,
      data.pros || [],
      data.cons || [],
      data.version || "v2",
      data.isAiIdentified ?? false,
      data.format || "",
      data.packageSize || "",
      data.description || "",
      data.ingredients || [],
      data.lastAnalysisAttempt,
      data.lastImageAttempt,
      data.translations
    );
  }

  toObject(): Product {
    return {
      barcode: this.barcode,
      name: this.name,
      brand: this.brand,
      foodType: this.foodType,
      protein: this.protein,
      fat: this.fat,
      moisture: this.moisture,
      carbs: this.carbs,
      fiber: this.fiber,
      ash: this.ash,
      imageUrl: this.imageUrl,
      score: this.score,
      pros: this.pros,
      cons: this.cons,
      version: this.version,
      isAiIdentified: this.isAiIdentified,
      format: this.format,
      packageSize: this.packageSize,
      description: this.description,
      ingredients: this.ingredients,
      lastAnalysisAttempt: this.lastAnalysisAttempt,
      lastImageAttempt: this.lastImageAttempt,
      translations: this.translations,
    };
  }
}

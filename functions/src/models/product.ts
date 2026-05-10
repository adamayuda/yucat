export type FoodType = "wet" | "dry" | "treat" | "topper" | "supplement";

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
    description = ""
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
      data.description || ""
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
    };
  }
}

import {Product, ProductModel} from "../models/product";

/**
 * Folds a back-label extraction into the product record it rescues.
 *
 * What the label is authoritative for: the macros, the score, pros/cons, the
 * ingredients and the description — that is the data the search failed to
 * find, read off the exact variant in the user's hand. What the existing
 * record keeps: its identity (name, brand, foodType), its display fields when
 * it has them, its image, and its key. The label photo itself is never the
 * product image (same rule as `resolveUserPhotoFallback`).
 *
 * `translations` are dropped: the six cached languages described the old,
 * empty analysis. `ensureTranslation` refills the requester's language on this
 * call and the others lazily, as on any fresh row.
 */
export function mergeLabelIntoProduct(
  existing: Product | null,
  extracted: Product,
  identification: {brand: string; name: string; foodType?: string} | undefined,
  opts: {gtin: string | null; requestId: string}
): Product {
  const base = existing ?? ProductModel.fromObject({}).toObject();
  const pick = (...values: (string | undefined)[]): string =>
    values.find((v) => typeof v === "string" && v.trim().length > 0) ?? "";

  const merged: Product = {
    ...base,
    name: pick(existing?.name, identification?.name, extracted.name),
    brand: pick(existing?.brand, identification?.brand, extracted.brand),
    foodType:
      existing?.foodType ??
      (identification?.foodType as Product["foodType"] | undefined) ??
      extracted.foodType,
    protein: extracted.protein,
    fat: extracted.fat,
    moisture: extracted.moisture,
    carbs: extracted.carbs,
    fiber: extracted.fiber,
    ash: extracted.ash,
    score: extracted.score,
    pros: extracted.pros,
    cons: extracted.cons,
    ingredients: extracted.ingredients ?? [],
    description: pick(extracted.description, existing?.description),
    format: pick(existing?.format, extracted.format),
    packageSize: pick(existing?.packageSize, extracted.packageSize),
    imageUrl: existing?.imageUrl ?? "",
    isAiIdentified: true,
    version: "v2",
    lastAnalysisAttempt: Date.now(),
    lastImageAttempt: existing?.lastImageAttempt,
    translations: undefined,
    gtin: existing?.gtin ?? opts.gtin ?? undefined,
    gtinSource: existing?.gtin ? existing.gtinSource : (opts.gtin ? "scan" : undefined),
    analysisSource: "label",
    labelRequestId: opts.requestId,
  };
  return merged;
}

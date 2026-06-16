/* eslint-disable max-len */
/**
 * Shared 0-100 nutritional-quality rubric.
 *
 * Used by BOTH the analyze step (new scans) and the batch re-score script so a
 * product is graded the same way everywhere. The key principle: **ingredient
 * quality matters as much as the macro numbers.** A food with great-looking
 * macros (high protein / low carb on a dry-matter basis) but poor ingredients
 * (plant-protein padding, added sugar, low real-meat %, vague "derivatives",
 * fillers) must NOT score as "excellent".
 */
export const QUALITY_RUBRIC = `
SCORING RUBRIC (0-100) — grade for an average healthy adult cat. Ingredient
quality counts as much as the macro numbers; do not reward good macros alone.

Start around 70 for an adequate complete food, then adjust:

Reward (push higher, toward 85-100):
- A named animal protein (e.g. "chicken", "salmon") as the clear main ingredient.
- High real-meat / animal content; named organs.
- High animal protein with low carbohydrate on a dry-matter basis.
- Appropriate moisture for the format; functional extras genuinely present
  (taurine, omega-3 / EPA-DHA, prebiotics, joint or urinary support).

Penalize (push lower, toward 30-60):
- Plant/vegetable protein used to inflate the protein figure (a high protein %
  that comes partly from plants is NOT high quality).
- Vague protein sources ("meat and animal derivatives", "meat by-products",
  unnamed "meat").
- Low real-meat percentage (e.g. "4% chicken").
- Added sugar / caramel; fillers (corn, wheat, soy, excessive cereals);
  artificial colours, flavours, or preservatives.
- High carbohydrate on a dry-matter basis.

Veterinary / therapeutic (prescription) diets — IMPORTANT:
- If the product is a clinical diet formulated for a medical condition — e.g.
  renal/kidney, urinary (struvite/oxalate, "Urinary S/O"), gastrointestinal/
  digestive, hepatic, hypoallergenic/sensitivity, diabetic, weight/satiety, or
  mobility/joint, often labelled "Veterinary Diet", "Prescription Diet", "Clinical
  Nutrition", "Renal", "Urinary", "Gastro Intestinal", etc. — grade it on how well
  it serves that therapeutic PURPOSE, not by general-food ingredient ideals.
- Do NOT penalize a therapeutic diet for by-products, named animal derivatives, or
  moderate cereal/carbohydrate content that are standard and clinically
  appropriate in such formulas (e.g. controlled protein/phosphorus for renal).
- A well-formulated therapeutic diet should typically score 78-92.
- This exception applies ONLY to genuine condition-specific clinical diets, not to
  ordinary retail lines (e.g. "indoor", "sterilised", "adult", "kitten").

Calibration:
- Great macros BUT sugar + plant protein + low real-meat % → mid/low (≈ 50-65),
  never "excellent".
- A genuinely high-meat, named-protein, low-carb food with clean ingredients →
  high (≈ 85-100).
`.trim();

/**
 * Prompt for the fast identification step.
 *
 * Output format is enforced by the `submit_identification` / `not_cat_food`
 * tool schemas — the prompt only describes the task, not the JSON shape.
 */
export function generateIdentificationPrompt(): string {
  return `
You are looking at a photo of a product. Read the packaging and decide:

1. Is this a CAT FOOD product? (Cat food = food, treats, toppers, or
   supplements explicitly intended for cats. Dog food, human food, and
   non-food items are NOT cat food.)

2. If yes, identify:
   - The brand name (e.g. "Royal Canin", "Hill's Science Diet").
   - The full product name including sub-brand, line, flavor, and variant
     (e.g. "Adult Indoor Sterilised Salmon Pouch", not just "Adult").
   - The food type — one of: wet, dry, treat, topper, supplement.

If the image does NOT show a cat food product, call the \`not_cat_food\`
tool. Otherwise call \`submit_identification\` with the brand, name, and
foodType.

Do not perform web searches in this step — base your answer entirely on
what is visible on the packaging.
`.trim();
}

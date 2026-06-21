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

ACCURACY RULES — the brand and name are used verbatim to search the web for
this exact product, so a wrong word makes the product unfindable:
   - Transcribe ONLY text that is actually printed on the package. Never
     invent, guess, infer, or translate words (e.g. do not add "Red", "in
     Sauce", or a texture that is not written on the label).
   - Exclude generic marketing taglines and slogans from BOTH the brand and
     the name (e.g. "Natural Pet Food", "Complete & Balanced", "Grain Free"
     as a banner, "Premium Quality"). These are not part of the product's
     identity and corrupt the search. Keep the manufacturer's actual brand
     name and the printed product/line/flavor/variant.
   - Capture the variant/texture exactly as printed (e.g. "Mini Fillets",
     "in Sauce", "Mousse") — do NOT substitute your own guess for the
     format. If the texture is not stated, leave it out rather than guessing.
   - If a word on the package is unclear or unreadable, omit it rather than
     guessing.

If the image does NOT show a cat food product, call the \`not_cat_food\`
tool. Otherwise call \`submit_identification\` with the brand, name, and
foodType.

Do not perform web searches in this step — base your answer entirely on
what is visible on the packaging.
`.trim();
}

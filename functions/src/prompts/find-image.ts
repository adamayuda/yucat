/**
 * Prompt for the image-only backfill step.
 *
 * Used when a cached/analyzed product has no usable `imageUrl`. The model uses
 * `web_search` to find a direct, hotlinkable product-shot URL and returns it via
 * the `submit_image_url` tool. Output shape is enforced by that tool schema.
 */
export function generateFindImagePrompt(brand: string, name: string): string {
  return `
You are finding a product photo for a cat food product so it can be displayed in
an app.

Product:
  brand: "${brand}"
  name: "${name}"

Your job:
1. Use the \`web_search\` tool (at most 2 searches) to find a clear product-shot
   image of THIS exact product — the packaging/pouch/can/bag on a plain
   background, from the official manufacturer page or a reputable retailer
   (e.g. Amazon, Chewy, PetSmart, the brand's own site).
2. Return a DIRECT image file URL — one that ends in or serves an image
   (.jpg/.jpeg/.png/.webp). Do NOT return a product/listing page URL.

Rules:
- Prefer a front-of-pack product shot over lifestyle photos with cats.
- If you cannot find a direct image URL for this exact product, return an empty
  string — never guess or fabricate a URL.

Call the \`submit_image_url\` tool with your answer. Do not write free text.
`.trim();
}

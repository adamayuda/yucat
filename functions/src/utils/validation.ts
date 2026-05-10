/**
 * Validates image data
 * @param {Buffer} imageData - The image data buffer
 * @param {number} minSize - Minimum acceptable size in bytes
 * @throws {Error} If image is invalid
 */
export function validateImageData(imageData: Buffer, minSize: number): void {
  if (imageData.length === 0) {
    throw new Error("Downloaded image is empty (0 bytes)");
  }

  if (imageData.length < minSize) {
    throw new Error(
      `Downloaded image is too small (${imageData.length} bytes) - ` +
      "likely invalid"
    );
  }
}

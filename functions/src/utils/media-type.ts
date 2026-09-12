/**
 * Sniffs the real image type from the first bytes of a base64 payload.
 *
 * Clients label everything `image/jpeg` — iOS `image_picker` returns no mime
 * for a PNG screenshot and a HEIC camera file — and the Anthropic API rejects
 * a mislabeled payload with a 400 ("image appears to be a different media type
 * than image/jpeg"). Trusting the bytes instead of the header makes the
 * declared type irrelevant.
 */

export type SniffedMediaType =
  | "image/jpeg"
  | "image/png"
  | "image/webp"
  | "image/gif"
  | "image/heic"
  | null;

export function sniffMediaType(base64: string): SniffedMediaType {
  // 24 base64 chars → 18 bytes, enough for every magic number below.
  const head = Buffer.from(base64.slice(0, 24), "base64");
  if (head.length < 12) return null;

  if (head[0] === 0xff && head[1] === 0xd8 && head[2] === 0xff) {
    return "image/jpeg";
  }
  if (
    head[0] === 0x89 && head[1] === 0x50 && head[2] === 0x4e && head[3] === 0x47
  ) {
    return "image/png";
  }
  if (head.toString("ascii", 0, 4) === "RIFF" &&
      head.toString("ascii", 8, 12) === "WEBP") {
    return "image/webp";
  }
  if (head.toString("ascii", 0, 3) === "GIF") {
    return "image/gif";
  }
  // ISO BMFF: bytes 4-8 are "ftyp", then the brand (heic/heix/hevc/mif1…).
  if (head.toString("ascii", 4, 8) === "ftyp") {
    const brand = head.toString("ascii", 8, 12);
    if (/^(heic|heix|hevc|hevx|mif1|msf1|heim|heis)$/.test(brand)) {
      return "image/heic";
    }
  }
  return null;
}

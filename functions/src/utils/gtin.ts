/**
 * GTIN (EAN/UPC) normalisation, mirrored in the Flutter client
 * (`lib/features/product/domain/utils/gtin.dart`). The client validates before
 * sending to save a round-trip on misreads; the server re-validates because it
 * never trusts input.
 *
 * Accepts GTIN-8, UPC-A (12), EAN-13 and GTIN-14. Returns the 13-digit form
 * (UPC-A left-padded; a GTIN-14 with a leading 0 stripped to its EAN-13), or
 * null when the check digit fails. The normalised string is what the cache
 * stores and filters on, so two scans of the same pack always agree.
 */
export function normalizeGtin(raw: unknown): string | null {
  if (typeof raw !== "string") return null;
  const digits = raw.replace(/\D/g, "");
  if (![8, 12, 13, 14].includes(digits.length)) return null;
  if (!hasValidCheckDigit(digits)) return null;

  if (digits.length === 12) return `0${digits}`;
  if (digits.length === 14) {
    // A GTIN-14 with packaging indicator 0 is the same trade item as its EAN-13.
    return digits.startsWith("0") ? digits.slice(1) : digits;
  }
  return digits;
}

/** Standard mod-10 check: weights alternate 3/1 from the right, excluding the check digit. */
function hasValidCheckDigit(digits: string): boolean {
  const body = digits.slice(0, -1);
  const check = Number(digits[digits.length - 1]);
  let sum = 0;
  for (let i = 0; i < body.length; i++) {
    const digit = Number(body[body.length - 1 - i]);
    sum += i % 2 === 0 ? digit * 3 : digit;
  }
  return (10 - (sum % 10)) % 10 === check;
}

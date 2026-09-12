/// GTIN (EAN/UPC) normalisation, mirrored by `functions/src/utils/gtin.ts`.
///
/// The client validates before sending so a misread barcode never costs a
/// round-trip; the backend re-validates because it never trusts input. Both
/// produce the same 13-digit form (UPC-A left-padded, a GTIN-14 with a leading
/// 0 stripped to its EAN-13), so the cache key agrees on both sides.
///
/// Returns null for anything that is not a GTIN-8/12/13/14 with a valid
/// mod-10 check digit.
String? normalizeGtin(String? raw) {
  if (raw == null) return null;
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (!const {8, 12, 13, 14}.contains(digits.length)) return null;
  if (!_hasValidCheckDigit(digits)) return null;

  if (digits.length == 12) return '0$digits';
  if (digits.length == 14) {
    return digits.startsWith('0') ? digits.substring(1) : digits;
  }
  return digits;
}

/// Weights alternate 3/1 from the right, excluding the check digit.
bool _hasValidCheckDigit(String digits) {
  final body = digits.substring(0, digits.length - 1);
  final check = int.parse(digits[digits.length - 1]);
  var sum = 0;
  for (var i = 0; i < body.length; i++) {
    final digit = int.parse(body[body.length - 1 - i]);
    sum += i.isEven ? digit * 3 : digit;
  }
  return (10 - (sum % 10)) % 10 == check;
}

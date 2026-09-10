/// Diacritic-insensitive lowercase key for searching, sorting and grouping
/// user-facing strings.
///
/// Folds the Latin-1 Supplement / Latin Extended-A letters that actually occur
/// in the fr / es / pt / de / hu copy we ship (é, è, ñ, ç, ő, ű, …) down to
/// their ASCII base letter. Three things in the breed picker depend on it, and
/// all three were silently ASCII-only before breed names were localized:
///
/// - **search** — "norvegien" typed without the accent must match "Norvégien";
/// - **sorting** — `compareTo` is UTF-16 code-unit order, so 'É' (0xC9) sorts
///   *after* 'Z' and "Européen" lands past "Sphynx";
/// - **A–Z grouping** — a header taken from a raw 'É' opens its own bucket
///   instead of filing under E.
///
/// ⚠️ This is deliberately **not** a locale-aware collator. Dart ships no ICU
/// collation and no pub package provides it, so a package would buy coverage we
/// don't need without buying the thing we'd actually want. Known deviation:
/// Hungarian alphabetizes the digraphs cs/gy/sz/zs as distinct letters; we file
/// them under c/g/s/z. Accepted for a 52-row option list.
String foldForSearch(String input) {
  final lower = input.toLowerCase();
  // Fast path: the typed query and every English label are pure ASCII.
  if (!lower.codeUnits.any((unit) => unit > 127)) return lower;

  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_foldings[char] ?? char);
  }
  return buffer.toString();
}

/// Keyed by the **lowercase** character — [foldForSearch] lowercases first, so
/// uppercase entries would be dead weight. Values may be multi-character
/// (æ → ae), which is why this maps to `String` rather than a code unit.
///
/// A map rather than two parallel strings on purpose: parallel strings fail
/// silently and unfixably if someone adds a character to one side only, and
/// there is no way to assert their lengths at const-init time.
const Map<String, String> _foldings = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ā': 'a',
  'ą': 'a', 'ă': 'a',
  'ç': 'c', 'ć': 'c', 'č': 'c',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ę': 'e', 'ě': 'e',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i', 'ı': 'i',
  'ñ': 'n', 'ń': 'n', 'ň': 'n',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o', 'ő': 'o',
  'ō': 'o',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ű': 'u', 'ū': 'u', 'ů': 'u',
  'ý': 'y', 'ÿ': 'y',
  'ś': 's', 'š': 's', 'ș': 's',
  'ź': 'z', 'ż': 'z', 'ž': 'z',
  'ď': 'd', 'đ': 'd', 'ğ': 'g', 'ł': 'l', 'ř': 'r', 'ť': 't', 'ț': 't',
  // Expansions, not strips — German and French readers expect these, and
  // 'ß' → 'ss' is also DIN 5007-1 dictionary order.
  'æ': 'ae', 'œ': 'oe', 'ß': 'ss',
};

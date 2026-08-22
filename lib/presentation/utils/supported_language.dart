/// The languages the app ships copy in. Mirrors `LANGUAGE_NAMES` in
/// `functions/src/prompts/languages.ts` — the two lists must stay in sync, or
/// content translated by the backend for a language the client won't ask for
/// (or vice versa) silently goes unused.
const Set<String> kSupportedLanguages = {'en', 'de', 'es', 'fr', 'hu', 'pt'};

/// The language whose copy is stored flat on a document, with every other
/// language living under `translations`.
const String kCanonicalLanguage = 'en';

/// Dart port of the backend's `normalizeLanguage`.
///
/// Accepts `"fr"`, `"fr_CA"` or `"fr-CA"` and returns the language subtag when
/// we support it. Returns `null` for anything else, which callers read as
/// "serve the canonical English copy".
String? normalizeLanguage(String? locale) {
  if (locale == null) return null;
  final lang = locale.trim().toLowerCase().split(RegExp(r'[-_]')).first;
  if (lang.isEmpty) return null;
  return kSupportedLanguages.contains(lang) ? lang : null;
}

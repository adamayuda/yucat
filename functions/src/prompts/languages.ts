/**
 * Single source of truth for the languages the app can render.
 *
 * These MUST stay in sync with the Flutter app's ARB files (`lib/l10n/app_*.arb`).
 * The map used to be duplicated in cat-narrative.ts and brand-verdict.ts, and both
 * copies had drifted — they covered only en/es/fr/hu, so German and Portuguese
 * users silently fell back to English.
 */

export const LANGUAGE_NAMES: Record<string, string> = {
  en: "English",
  es: "Spanish",
  fr: "French",
  hu: "Hungarian",
  de: "German",
  pt: "Portuguese",
};

/** Canonical language used for the stored product record. */
export const CANONICAL_LANGUAGE = "en";

/**
 * Normalizes an incoming locale to a supported language code.
 *
 * Accepts a bare code ("fr") or a full locale ("fr_CA" / "fr-CA") and returns the
 * language subtag when we support it, otherwise `undefined`. Callers treat
 * `undefined` as "serve the canonical English text".
 */
export function normalizeLanguage(locale?: unknown): string | undefined {
  if (typeof locale !== "string") return undefined;
  const lang = locale.trim().toLowerCase().split(/[-_]/)[0];
  if (!lang) return undefined;
  return lang in LANGUAGE_NAMES ? lang : undefined;
}

/** English name of a language code, for use inside a prompt. */
export function languageName(lang: string): string {
  return LANGUAGE_NAMES[lang] ?? "English";
}

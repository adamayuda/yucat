import 'package:flutter/widgets.dart';

/// Resolves a locale-specific asset path using the `<base>-<lang>.<ext>` scheme,
/// e.g. `localizedAssetPath(context, 'assets/images/onboarding-cards', 'svg')`
/// → `assets/images/onboarding-cards-fr.svg` when the current locale is French.
///
/// Flutter has no built-in per-locale asset resolution, so we pick the path from
/// [Localizations.localeOf]. Any locale not in [available] (the locales we
/// actually have art for) falls back to `-en`, so callers never reference a
/// missing file — important for `SvgPicture.asset`, which has no `errorBuilder`.
String localizedAssetPath(
  BuildContext context,
  String basePath,
  String ext, {
  Set<String> available = const {'en', 'es', 'fr', 'hu'},
}) {
  final lang = Localizations.localeOf(context).languageCode;
  final code = available.contains(lang) ? lang : 'en';
  return '$basePath-$code.$ext';
}

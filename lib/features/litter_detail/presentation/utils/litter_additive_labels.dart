import 'package:yucat/l10n/app_localizations.dart';

/// Localizes the additive names the backend returns.
///
/// `additives` is canonical English and is **not** one of the five `LitterText`
/// fields the backend translates, so without this every locale would render
/// "Baking soda". The set of additives that actually recur on litter packaging
/// is small and stable, so a client-side lookup is cheaper and more predictable
/// than another model call.
///
/// Anything unrecognized falls through to the backend string unchanged — an
/// unusual additive still shows, in English, rather than disappearing.
String litterAdditiveLabel(String additive, AppLocalizations l10n) {
  final normalized = additive.trim().toLowerCase();
  if (normalized.isEmpty) return additive;

  for (final entry in _matchers) {
    for (final needle in entry.needles) {
      if (normalized.contains(needle)) return entry.label(l10n);
    }
  }
  return additive;
}

typedef _Matcher = ({
  List<String> needles,
  String Function(AppLocalizations) label,
});

/// Order matters: the first match wins, so more specific needles come first.
/// "Activated charcoal" must be tested before the bare "carbon" that also
/// appears inside "sodium carbonate".
const List<_Matcher> _matchers = [
  (
    needles: ['activated charcoal', 'activated carbon', 'charcoal'],
    label: _activatedCharcoal,
  ),
  (
    needles: ['baking soda', 'sodium bicarbonate', 'bicarbonate of soda'],
    label: _bakingSoda,
  ),
  (
    needles: ['essential oil'],
    label: _essentialOils,
  ),
  (
    needles: ['fragrance', 'perfume', 'parfum'],
    label: _fragrance,
  ),
  (
    needles: ['plant starch', 'corn starch', 'starch'],
    label: _plantStarch,
  ),
  (
    needles: ['zeolite'],
    label: _zeolite,
  ),
  (
    needles: ['silica', 'silicate'],
    label: _silica,
  ),
  (
    needles: ['deodoriz', 'deodoris', 'odour neutral', 'odor neutral'],
    label: _deodorizer,
  ),
];

String _activatedCharcoal(AppLocalizations l) => l.litterAdditiveActivatedCharcoal;
String _bakingSoda(AppLocalizations l) => l.litterAdditiveBakingSoda;
String _essentialOils(AppLocalizations l) => l.litterAdditiveEssentialOils;
String _fragrance(AppLocalizations l) => l.litterAdditiveFragrance;
String _plantStarch(AppLocalizations l) => l.litterAdditivePlantStarch;
String _zeolite(AppLocalizations l) => l.litterAdditiveZeolite;
String _silica(AppLocalizations l) => l.litterAdditiveSilica;
String _deodorizer(AppLocalizations l) => l.litterAdditiveDeodorizer;

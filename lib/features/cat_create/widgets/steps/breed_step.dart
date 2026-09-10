import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/presentation/utils/cat_labels.dart';
import 'package:yucat/features/search_products/presentation/widgets/search_text_field.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';
import 'package:yucat/presentation/utils/search_fold.dart';

const _mixedBreedValue = 'Other';

/// One selectable breed, precomputed once per locale.
///
/// `value` is stable and English; only `label` is localized — the same split
/// `coat_step.dart` and `health_conditions_step.dart` use. `sortKey` and
/// `haystack` are its folded derivatives, held here so neither sorting nor
/// filtering has to re-fold on every frame.
typedef _BreedOption = ({
  String value,
  String label,
  String sortKey,
  String haystack,
});

/// The wizard's breed picker: a searchable, A–Z grouped list of ~52 breeds with
/// a pinned "Mixed / unknown" escape hatch.
class BreedStep extends StatefulWidget {
  final String? selectedBreed;
  final List<String> breeds;
  final ValueChanged<String> onBreedSelected;

  const BreedStep({
    super.key,
    required this.selectedBreed,
    required this.breeds,
    required this.onBreedSelected,
  });

  @override
  State<BreedStep> createState() => _BreedStepState();
}

class _BreedStepState extends State<BreedStep> {
  final TextEditingController _searchController = TextEditingController();

  /// Owned so the list can be snapped back to the top when the query changes.
  /// Without it, filtering a scrolled-down list clamps the offset to the new,
  /// shorter extent and drops the user into the middle of the results.
  final ScrollController _scrollController = ScrollController();

  /// Raw, as typed. Folded in [build] — folding one short string per keystroke
  /// isn't worth a second field to memoize.
  String _query = '';

  /// Localized, folded and sorted. Rebuilt only when the locale changes.
  List<_BreedOption> _options = const [];

  /// [_options] bucketed by folded first letter. Insertion-ordered, so the A–Z
  /// headers come out already sorted. Only used when no query is active.
  Map<String, List<_BreedOption>> _groups = const {};

  Locale? _builtForLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ⚠️ Guarded on the locale, not just called. didChangeDependencies fires on
    // any inherited-widget change — including the MediaQuery viewInsets that
    // this step's own search field changes every time it takes focus. Same
    // guard shape as recipes_page.dart.
    final locale = Localizations.localeOf(context);
    if (locale == _builtForLocale) return;
    _builtForLocale = locale;
    _rebuildOptions(AppLocalizations.of(context));
  }

  @override
  void didUpdateWidget(BreedStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Defensive: `breeds` is a const static today, so this never fires.
    if (!identical(widget.breeds, oldWidget.breeds)) {
      _rebuildOptions(AppLocalizations.of(context));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// English values → localized labels → fold → sort → group A–Z.
  ///
  /// Doing it here rather than in `build` isn't about speed (52 rows is
  /// microseconds); it's so the keystroke path is a plain filter over a flat
  /// list, with no sorting and no grouping in it at all.
  void _rebuildOptions(AppLocalizations l10n) {
    final options = <_BreedOption>[];
    for (final value in widget.breeds) {
      // "Other" is dropped here: it surfaces as the pinned "Mixed / unknown"
      // affordance below the list and is never part of the A–Z run or search.
      if (value == _mixedBreedValue) continue;
      final label = catFormatBreed(value, l10n);
      final labelKey = foldForSearch(label);
      final valueKey = foldForSearch(value);
      options.add((
        value: value,
        label: label,
        // Vets and breeders use the English names whatever the app language,
        // so "norwegian" also finds "Norvégien". Skipped when the locale is
        // English and the two are already the same string.
        haystack: labelKey == valueKey ? labelKey : '$labelKey $valueKey',
        sortKey: labelKey,
      ));
    }

    // Folded compare, so "Européen" sorts between "Devon Rex" and "Exotic
    // Shorthair" — a raw compareTo puts 'É' (0xC9) after 'Z'. Tie-break on the
    // raw label so two names folding to one key keep a stable order.
    options.sort((a, b) {
      final byKey = a.sortKey.compareTo(b.sortKey);
      return byKey != 0 ? byKey : a.label.compareTo(b.label);
    });

    final groups = <String, List<_BreedOption>>{};
    for (final option in options) {
      // From the folded key, so "Européen" files under E instead of opening its
      // own "É" bucket at the end of the list.
      final letter = option.sortKey[0].toUpperCase();
      groups.putIfAbsent(letter, () => []).add(option);
    }

    setState(() {
      _options = options;
      _groups = groups;
    });
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  void _onClear() {
    _searchController.clear();
    _onQueryChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final needle = foldForSearch(_query.trim());
    final searching = needle.isNotEmpty;
    final matches = searching
        ? _options.where((o) => o.haystack.contains(needle)).toList()
        : const <_BreedOption>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MascotSpeechBubble(question: l10n.breedQuestion),
        const SizedBox(height: DSDimens.sizeS),
        // No horizontal padding — create_cat_page already insets every step by
        // DSDimens.sizeL.
        SearchTextField(
          controller: _searchController,
          hintText: l10n.breedSearchHint,
          onChanged: _onQueryChanged,
          onClear: _onClear,
          // The field renders a "search" return key, so it has to do
          // something. Dismissing is the honest action — auto-selecting a lone
          // match would mutate the profile from a keypress.
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          // ⚠️ Never autofocus. All 12 wizard pages are eagerly built (PageView
          // with `children`, not `.builder`), so this widget is mounted while
          // the user is still on step 0 — autofocus would raise the keyboard
          // over the name step.
          autofocus: false,
        ),
        const SizedBox(height: DSDimens.sizeXs),
        Expanded(
          child: ListView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            // Clears the floating Next button.
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              if (!searching)
                ..._groupedRows()
              else if (matches.isEmpty)
                _noResults(l10n)
              else
                // No A–Z headers while filtering: one header per result is
                // noise, and `where` already preserves the sorted order.
                for (final option in matches) ...[
                  _row(option),
                  const SizedBox(height: DSDimens.sizeXxs),
                ],
              const SizedBox(height: DSDimens.sizeS),
              // "Mixed / unknown" is a real option row, not a text link: it is
              // the default value, so a link gave no feedback at all when
              // tapped (nothing to select, nothing to advance to).
              //
              // It stays visible while filtering, for two reasons: it is the
              // escape hatch, most useful exactly when a search finds nothing;
              // and it is the *persisted default* (`cat.breed ?? 'Other'`), so
              // hiding it would leave the step with nothing selected while Next
              // still advanced the wizard.
              _caption(l10n.breedUnknownPrefix.trim()),
              DSOptionRow(
                label: l10n.breedMixedUnknown,
                selected: widget.selectedBreed == _mixedBreedValue,
                onTap: () => widget.onBreedSelected(_mixedBreedValue),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _groupedRows() => [
    for (final entry in _groups.entries) ...[
      _caption(entry.key),
      for (final option in entry.value) ...[
        _row(option),
        const SizedBox(height: DSDimens.sizeXxs),
      ],
    ],
  ];

  Widget _row(_BreedOption option) => DSOptionRow(
    label: option.label,
    selected: widget.selectedBreed == option.value,
    // ⚠️ The canonical English `value` goes to the bloc, never `label`.
    // Passing the label would write "Norvégien" into Firestore, break the
    // English literal matching in both rules engines, and split the Mixpanel
    // `cat_breed` property six ways.
    onTap: () => widget.onBreedSelected(option.value),
  );

  /// A filter miss, not an empty state — the data loaded fine and a valid
  /// action sits one row below. So one line in the list flow rather than
  /// `DSStateView.empty`, whose 200px centred mascot has nowhere to go with the
  /// keyboard up and would push the escape hatch off screen.
  Widget _noResults(AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: DSDimens.sizeXs,
      vertical: DSDimens.sizeM,
    ),
    child: Text(
      l10n.breedSearchNoResults(_query.trim()),
      textAlign: TextAlign.center,
      style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkSecondary),
    ),
  );

  Widget _caption(String text) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: DSDimens.sizeXs,
      vertical: DSDimens.sizeXxs,
    ),
    child: Text(
      text,
      style: DSTextStyles.caption.copyWith(
        color: DSColors.inkTertiary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

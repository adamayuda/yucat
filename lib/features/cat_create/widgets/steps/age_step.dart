import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoPicker, FixedExtentScrollController;
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

/// Age in years + months on two wheels, or — for owners who know it — the
/// exact birthday. The birthday is what the health carnet's kitten series runs
/// on; the wheels are a snapshot that never ages.
///
/// The two inputs are exclusive by construction: picking a birthday re-seeds
/// the wheels from it, and moving a wheel afterwards clears the birthday (the
/// page does that via `clearBirthDate`), so the profile never carries a date
/// that contradicts the months.
class AgeStep extends StatefulWidget {
  final int? age;
  final DateTime? birthDate;
  final ValueChanged<int?> onAgeChanged;
  final ValueChanged<DateTime> onBirthDateChanged;

  const AgeStep({
    super.key,
    required this.age,
    required this.onAgeChanged,
    required this.onBirthDateChanged,
    this.birthDate,
  });

  /// Age is stored as a flat month count. The two-column picker splits it into
  /// years (0–[maxYears]) and months (0–11).
  static const int maxYears = 25;

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  late FixedExtentScrollController _yearsController;
  late FixedExtentScrollController _monthsController;
  late int _years;
  late int _months;

  /// True while the wheels are being re-seeded from a picked birthday, so the
  /// resulting `onSelectedItemChanged` is not mistaken for the user moving a
  /// wheel — which would clear the birthday they just chose.
  bool _seeding = false;

  @override
  void didUpdateWidget(covariant AgeStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    final months = widget.age;
    if (months == null || months == _totalMonths) return;
    final clamped = months.clamp(0, AgeStep.maxYears * 12 + 11);
    _seeding = true;
    setState(() {
      _years = clamped ~/ 12;
      _months = clamped % 12;
    });
    // Jump after the frame: `didUpdateWidget` runs mid-build, and a scroll
    // jump from there would touch layout while it is being computed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _yearsController.jumpToItem(_years);
      _monthsController.jumpToItem(_months);
      WidgetsBinding.instance.addPostFrameCallback((_) => _seeding = false);
    });
  }

  void _onWheel() {
    if (_seeding) return;
    widget.onAgeChanged(_totalMonths);
  }

  Future<void> _pickBirthday() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.birthDate ??
          now.subtract(Duration(days: (_totalMonths * 30.4375).round())),
      firstDate: DateTime(now.year - AgeStep.maxYears),
      lastDate: now,
      helpText: l10n.ageBirthdayPickerHelp,
    );
    if (!mounted || picked == null) return;
    widget.onBirthDateChanged(picked);
  }

  @override
  void initState() {
    super.initState();
    final initialMonths = (widget.age ?? 18).clamp(0, AgeStep.maxYears * 12 + 11);
    _years = initialMonths ~/ 12;
    _months = initialMonths % 12;
    _yearsController = FixedExtentScrollController(initialItem: _years);
    _monthsController = FixedExtentScrollController(initialItem: _months);
    if (widget.age == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAgeChanged(_totalMonths);
      });
    }
  }

  int get _totalMonths => _years * 12 + _months;

  @override
  void dispose() {
    _yearsController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  String _stageLabel(AppLocalizations l10n, int months) {
    final years = (months / 12).toStringAsFixed(1);
    if (months < 12) {
      return l10n.ageStageKitten(years);
    }
    // Same bound as `ageGroupFromMonths` — the engines call a cat "senior"
    // from 10 years, and this tip must not say so three years earlier.
    if (months < 120) {
      return l10n.ageStageAdult(years);
    }
    return l10n.ageStageSenior(years);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MascotSpeechBubble(question: l10n.ageQuestion),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: _columnHeader(l10n.ageColumnYears)),
                    Expanded(child: _columnHeader(l10n.ageColumnMonths)),
                  ],
                ),
                const SizedBox(height: DSDimens.sizeXs),
                SizedBox(
                  height: 220,
                  child: Row(
                    children: [
                      Expanded(
                        child: _wheel(
                          controller: _yearsController,
                          count: AgeStep.maxYears + 1,
                          current: _years,
                          unit: l10n.ageUnitYear,
                          onChanged: (value) {
                            setState(() => _years = value);
                            _onWheel();
                          },
                        ),
                      ),
                      Expanded(
                        child: _wheel(
                          controller: _monthsController,
                          count: 12,
                          current: _months,
                          unit: l10n.ageUnitMonth,
                          onChanged: (value) {
                            setState(() => _months = value);
                            _onWheel();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
          padding: const EdgeInsets.all(DSDimens.sizeS),
          decoration: BoxDecoration(
            color: DSColors.surfaceCardDim,
            borderRadius: BorderRadius.circular(DSRadii.md),
          ),
          child: Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: DSDimens.sizeXxs),
              Expanded(
                child: Text(
                  _stageLabel(l10n, _totalMonths),
                  style: DSTextStyles.bodyMd,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DSDimens.sizeXs),
        Center(child: _birthdayRow(l10n)),
        const SizedBox(height: DSDimens.sizeS),
      ],
    );
  }

  /// "Know the exact birthday?" until one is picked, then the date with a
  /// "Change" link. Formatted by `MaterialLocalizations` so the six locales
  /// each get their own medium date without a new dependency.
  Widget _birthdayRow(AppLocalizations l10n) {
    final birthDate = widget.birthDate;
    if (birthDate == null) {
      return DSTextLink(
        label: l10n.ageKnowBirthday,
        onPressed: _pickBirthday,
        trailingIcon: Icons.cake_outlined,
      );
    }
    final formatted = MaterialLocalizations.of(context).formatMediumDate(birthDate);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: DSDimens.sizeXxs,
      children: [
        Text(
          l10n.ageBornOn(formatted),
          style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkSecondary),
        ),
        DSTextLink(label: l10n.ageChangeBirthday, onPressed: _pickBirthday),
      ],
    );
  }

  Widget _columnHeader(String label) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkTertiary),
    );
  }

  Widget _wheel({
    required FixedExtentScrollController controller,
    required int count,
    required int current,
    required String unit,
    required ValueChanged<int> onChanged,
  }) {
    return CupertinoPicker.builder(
      scrollController: controller,
      itemExtent: 56,
      selectionOverlay: const SizedBox.shrink(),
      childCount: count,
      onSelectedItemChanged: onChanged,
      itemBuilder: (context, index) {
        final isCenter = index == current;
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$index',
                style: DSTextStyles.displayHero.copyWith(
                  fontSize: isCenter ? 44 : 26,
                  color: isCenter ? DSColors.inkPrimary : DSColors.inkTertiary,
                ),
              ),
              if (isCenter) ...[
                const SizedBox(width: DSDimens.sizeXxxs),
                Text(
                  unit,
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_protocol.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_date_format.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/health_date_row.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/lifestyle_card.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// The three protocols the setup asks about, in order. Each answer becomes one
/// `done` record, which is what turns a wall of undated "to schedule" rows into
/// a real, dated schedule on day one.
///
/// "Last vaccine" maps to FVRCP — the core vaccine every cat has — not rabies,
/// whose booster interval is a property of the vial and needs its own question
/// (the add sheet asks it). Deworming is the internal one; the external
/// antiparasitic is monthly and rarely remembered to the day.
const _kSetupProtocolIds = ['fvrcp', 'deworming_internal', 'annual_checkup'];

/// Three dates plus one lifestyle question.
const _kStepCount = 4;
const _kLifestyleStep = 3;

/// What the setup sheet hands back: the dated records to write and, when the
/// owner answered it, the lifestyle. Both optional — every step is skippable.
class HealthSetupResult {
  final List<HealthEventEntity> drafts;
  final String? lifestyle;

  const HealthSetupResult({required this.drafts, this.lifestyle});

  bool get isEmpty => drafts.isEmpty && lifestyle == null;
}

/// First-open setup: three dates and one question, each skippable.
///
/// Returns the result (possibly empty when every step was skipped), or null
/// when the sheet was dismissed by the barrier. Persistence is the bloc's
/// job — see `HealthCarnetSetupCompletedEvent`, which writes the lifestyle
/// first (it changes the schedule the records feed) and then the records
/// sequentially rather than firing three add events that would race.
Future<HealthSetupResult?> showHealthSetupSheet(
  BuildContext context, {
  required CatEntity cat,
}) {
  return showModalBottomSheet<HealthSetupResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _HealthSetupSheet(cat: cat),
  );
}

class _HealthSetupSheet extends StatefulWidget {
  final CatEntity cat;

  const _HealthSetupSheet({required this.cat});

  @override
  State<_HealthSetupSheet> createState() => _HealthSetupSheetState();
}

class _HealthSetupSheetState extends State<_HealthSetupSheet> {
  int _step = 0;
  final List<DateTime?> _dates = List.filled(_kSetupProtocolIds.length, null);
  String? _lifestyle;

  bool get _isLast => _step == _kStepCount - 1;
  bool get _isLifestyleStep => _step == _kLifestyleStep;

  /// Whether the current step has an answer to move on with.
  bool get _canAdvance =>
      _isLifestyleStep ? _lifestyle != null : _dates[_step] != null;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dates[_step] ?? now,
      firstDate: DateTime(now.year - 25),
      // Same bound as the add sheet: these are things that already happened.
      lastDate: now,
    );
    if (!mounted || picked == null) return;
    setState(() => _dates[_step] = picked);
  }

  void _advance({required bool skip}) {
    if (skip) {
      if (_isLifestyleStep) {
        _lifestyle = null;
      } else {
        _dates[_step] = null;
      }
    }
    if (!_isLast) {
      setState(() => _step += 1);
      return;
    }
    Navigator.of(context).pop(
      HealthSetupResult(drafts: _drafts(), lifestyle: _lifestyle),
    );
  }

  List<HealthEventEntity> _drafts() {
    final drafts = <HealthEventEntity>[];
    for (var i = 0; i < _kSetupProtocolIds.length; i++) {
      final date = _dates[i];
      if (date == null) continue;
      final protocol = HealthProtocols.byId(_kSetupProtocolIds[i])!;
      drafts.add(HealthEventEntity(
        protocolId: protocol.id,
        category: protocol.category,
        // Protocol-backed records store an empty title on purpose — the
        // timeline names them from the protocol, in whatever language the
        // user reads later.
        title: '',
        status: HealthEventStatus.done,
        performedAt: date,
      ));
    }
    return drafts;
  }

  String _question(AppLocalizations l10n) => switch (_step) {
        0 => l10n.healthSetupQuestionVaccine,
        1 => l10n.healthSetupQuestionDeworming,
        2 => l10n.healthSetupQuestionCheckup,
        _ => l10n.healthLifestyleQuestion(widget.cat.name),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = healthLocaleOf(context);
    final date = _isLifestyleStep ? null : _dates[_step];

    return Container(
      decoration: const BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadii.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DSDimens.sizeL,
            DSDimens.sizeS,
            DSDimens.sizeL,
            DSDimens.sizeL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DSColors.surfaceCardDim,
                    borderRadius: BorderRadius.circular(DSRadii.pill),
                  ),
                ),
              ),
              const SizedBox(height: DSDimens.sizeL),
              Text(
                l10n.healthSetupTitle(widget.cat.name),
                style: DSTextStyles.titleMd,
              ),
              const SizedBox(height: DSDimens.sizeXxs),
              Text(
                l10n.healthSetupIntro,
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkSecondary,
                ),
              ),
              const SizedBox(height: DSDimens.sizeL),
              _StepDots(current: _step, count: _kStepCount),
              const SizedBox(height: DSDimens.sizeS),
              // Keyed so the switch reads as a new question, not a relabel.
              AnimatedSwitcher(
                duration: DSMotion.durFast,
                switchInCurve: DSMotion.curveStandard,
                child: Column(
                  key: ValueKey(_step),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_question(l10n), style: DSTextStyles.headlineMd),
                    const SizedBox(height: DSDimens.sizeS),
                    if (_isLifestyleStep)
                      LifestyleOptions(
                        selected: _lifestyle,
                        onSelect: (v) => setState(() => _lifestyle = v),
                      )
                    else
                      HealthDateRow(
                        label: l10n.healthAddFieldDateLabel,
                        value: date == null
                            ? l10n.healthSetupPickDate
                            : healthFormatDate(date, locale),
                        placeholder: date == null,
                        onTap: _pickDate,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: DSDimens.sizeL),
              DSPillButton(
                label: _isLast ? l10n.healthSetupFinish : l10n.commonNext,
                onPressed: _canAdvance ? () => _advance(skip: false) : null,
                showChevron: !_isLast,
              ),
              const SizedBox(height: DSDimens.sizeXs),
              Center(
                child: DSTextLink(
                  label: l10n.healthSetupDontKnow,
                  onPressed: () => _advance(skip: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Four small dots; the current step is ink, the rest dim. Kept local rather
/// than using `DSDotIndicator`, which is bound to a `PageController` — this
/// sheet has no page view, since a `PageView` needs a fixed height that a
/// bottom sheet sized to its content cannot give it.
class _StepDots extends StatelessWidget {
  final int current;
  final int count;

  const _StepDots({required this.current, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          AnimatedContainer(
            duration: DSMotion.durFast,
            width: i == current ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == current
                  ? DSColors.accentInfo
                  : DSColors.surfaceCardDim,
              borderRadius: BorderRadius.circular(DSRadii.pill),
            ),
          ),
          if (i < count - 1) const SizedBox(width: DSDimens.sizeXxxs),
        ],
      ],
    );
  }
}

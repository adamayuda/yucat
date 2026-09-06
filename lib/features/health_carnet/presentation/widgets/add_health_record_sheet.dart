import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_protocol.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_date_format.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// Freeform categories offered alongside the protocol catalogue, for acts no
/// protocol schedules — an illness, an X-ray, a one-off medication course.
const _kFreeformCategories = <HealthCategory>[
  HealthCategory.exam,
  HealthCategory.lab,
  HealthCategory.dental,
  HealthCategory.surgery,
  HealthCategory.treatment,
  HealthCategory.weight,
  HealthCategory.other,
];

/// Two-step "+ Ajouter un acte" sheet: pick what happened, then describe it.
///
/// Returns the unsaved draft, or null if dismissed — persistence is the bloc's
/// job, so this stays a pure input widget.
///
/// Follows `_showPhotoSourceSheet` in `profile_photo_step.dart`, the app's only
/// other modal sheet: transparent barrier, own rounded container, grab handle,
/// `SafeArea(top: false)`.
Future<HealthEventEntity?> showAddHealthRecordSheet(BuildContext context) {
  return showModalBottomSheet<HealthEventEntity>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _AddHealthRecordSheet(),
  );
}

class _AddHealthRecordSheet extends StatefulWidget {
  const _AddHealthRecordSheet();

  @override
  State<_AddHealthRecordSheet> createState() => _AddHealthRecordSheetState();
}

class _AddHealthRecordSheetState extends State<_AddHealthRecordSheet> {
  HealthProtocol? _protocol;
  HealthCategory? _freeformCategory;
  bool _picked = false;

  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _vetController = TextEditingController();
  final _clinicController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime _date = DateTime.now();

  /// Rabies only: the booster interval is a property of the vial the vet used,
  /// so it has to be asked rather than assumed. Defaults to the conservative
  /// one year.
  int _rabiesIntervalDays = 365;

  bool _titleMissing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _vetController.dispose();
    _clinicController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
        decoration: const BoxDecoration(
          color: DSColors.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadii.xl)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: DSDimens.sizeS),
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
              Flexible(child: _picked ? _buildForm() : _buildPicker()),
            ],
          ),
        ),
      ),
    );
  }

  // --- Step 1: what happened ------------------------------------------------

  Widget _buildPicker() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeL,
        DSDimens.sizeL,
        DSDimens.sizeL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.healthAddSheetTitle, style: DSTextStyles.titleMd),
          const SizedBox(height: DSDimens.sizeS),
          Text(l10n.healthAddSectionCare, style: DSTextStyles.label),
          const SizedBox(height: DSDimens.sizeXxs),
          for (final protocol in HealthProtocols.all) ...[
            DSOptionRow(
              label: healthProtocolName(protocol.id, l10n),
              description: healthProtocolDescription(protocol.id, l10n),
              leadingIcon: healthCategoryIcon(protocol.category),
              onTap: () => _select(protocol: protocol),
            ),
            const SizedBox(height: DSDimens.sizeXxs),
          ],
          const SizedBox(height: DSDimens.sizeXs),
          Text(l10n.healthAddSectionOther, style: DSTextStyles.label),
          const SizedBox(height: DSDimens.sizeXxs),
          for (final category in _kFreeformCategories) ...[
            DSOptionRow(
              label: healthCategoryLabel(category, l10n),
              leadingIcon: healthCategoryIcon(category),
              onTap: () => _select(category: category),
            ),
            const SizedBox(height: DSDimens.sizeXxs),
          ],
        ],
      ),
    );
  }

  void _select({HealthProtocol? protocol, HealthCategory? category}) {
    setState(() {
      _protocol = protocol;
      _freeformCategory = category;
      _picked = true;
    });
  }

  // --- Step 2: describe it --------------------------------------------------

  Widget _buildForm() {
    final l10n = AppLocalizations.of(context);
    final locale = healthLocaleOf(context);
    final protocol = _protocol;
    final isFreeform = protocol == null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeL,
        DSDimens.sizeL,
        DSDimens.sizeL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _picked = false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.chevron_left,
                  color: DSColors.inkPrimary,
                  size: 26,
                ),
              ),
              const SizedBox(width: DSDimens.sizeXxs),
              Expanded(
                child: Text(
                  isFreeform
                      ? healthCategoryLabel(_freeformCategory!, l10n)
                      : healthProtocolName(protocol.id, l10n),
                  style: DSTextStyles.titleMd,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeS),

          // A protocol-backed record carries **no** title: the timeline renders
          // it from `protocolId`, so it stays correct if the user changes app
          // language. Only a freeform act needs one.
          if (isFreeform) ...[
            _Field(
              label: l10n.healthAddFieldTitleLabel,
              controller: _titleController,
              hint: l10n.healthAddFieldTitleHint,
              errorText: _titleMissing ? l10n.healthAddTitleRequired : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: DSDimens.sizeS),
          ],

          _DateRow(
            label: l10n.healthAddFieldDateLabel,
            value: healthFormatDate(_date, locale),
            onTap: _pickDate,
          ),
          const SizedBox(height: DSDimens.sizeS),

          if (protocol?.id == 'rabies') ...[
            Text(l10n.healthAddRabiesIntervalLabel, style: DSTextStyles.label),
            const SizedBox(height: DSDimens.sizeXxs),
            Row(
              children: [
                Expanded(
                  child: _IntervalChoice(
                    label: l10n.healthAddRabiesOneYear,
                    selected: _rabiesIntervalDays == 365,
                    onTap: () => setState(() => _rabiesIntervalDays = 365),
                  ),
                ),
                const SizedBox(width: DSDimens.sizeXxs),
                Expanded(
                  child: _IntervalChoice(
                    label: l10n.healthAddRabiesThreeYears,
                    selected: _rabiesIntervalDays == 1095,
                    onTap: () => setState(() => _rabiesIntervalDays = 1095),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSDimens.sizeS),
          ],

          _Field(
            label: l10n.healthAddFieldWeightLabel,
            controller: _weightController,
            hint: l10n.healthAddFieldWeightHint,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
          ),
          const SizedBox(height: DSDimens.sizeS),
          _Field(
            label: l10n.healthAddFieldNotesLabel,
            controller: _notesController,
            hint: l10n.healthAddFieldNotesHint,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: DSDimens.sizeS),
          Row(
            children: [
              Expanded(
                child: _Field(
                  label: l10n.healthAddFieldVetLabel,
                  controller: _vetController,
                  hint: l10n.healthAddFieldVetHint,
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: DSDimens.sizeXs),
              Expanded(
                child: _Field(
                  label: l10n.healthAddFieldClinicLabel,
                  controller: _clinicController,
                  hint: l10n.healthAddFieldClinicHint,
                  textCapitalization: TextCapitalization.words,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeL),
          DSPillButton(
            label: l10n.healthAddSave,
            onPressed: _submit,
            showChevron: false,
          ),
          const SizedBox(height: DSDimens.sizeXxs),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.healthAddCancel,
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 25),
      // A record is something that already happened. Scheduling a future
      // appointment is a different affordance and is not offered here.
      lastDate: now,
    );
    if (!mounted || picked == null) return;
    setState(() => _date = picked);
  }

  void _submit() {
    final protocol = _protocol;
    final title = _titleController.text.trim();

    if (protocol == null && title.isEmpty) {
      setState(() => _titleMissing = true);
      return;
    }

    final weight = double.tryParse(
      _weightController.text.trim().replaceAll(',', '.'),
    );

    Navigator.of(context).pop(
      HealthEventEntity(
        protocolId: protocol?.id,
        category: protocol?.category ?? _freeformCategory ?? HealthCategory.other,
        title: protocol == null ? title : '',
        notes: _emptyToNull(_notesController.text),
        status: HealthEventStatus.done,
        performedAt: _date,
        intervalDays: protocol?.id == 'rabies' ? _rabiesIntervalDays : null,
        weightKg: weight,
        vetName: _emptyToNull(_vetController.text),
        clinic: _emptyToNull(_clinicController.text),
      ),
    );
  }

  static String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// Labelled text input.
///
/// ⚠️ Built from scratch rather than leaning on
/// `AppTheme.lightTheme.inputDecorationTheme`, which still points at the legacy
/// palette (`inputLightGrey` fill, `DSColors.black` labels). Every real input in
/// the app overrides it for the same reason.
class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? errorText;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.errorText,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DSTextStyles.label),
        const SizedBox(height: DSDimens.sizeXxs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSDimens.sizeXs,
            vertical: DSDimens.sizeXxs,
          ),
          decoration: BoxDecoration(
            color: DSColors.surfaceCardDim,
            borderRadius: BorderRadius.circular(DSRadii.md),
            border: errorText == null
                ? null
                : Border.all(color: DSColors.accentDanger),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            cursorColor: DSColors.coralAccent,
            style: DSTextStyles.bodyLg,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: DSTextStyles.bodyLg.copyWith(
                color: DSColors.inkTertiary,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: DSDimens.sizeXxxs),
          Text(
            errorText!,
            style: DSTextStyles.caption.copyWith(color: DSColors.accentDanger),
          ),
        ],
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DSTextStyles.label),
        const SizedBox(height: DSDimens.sizeXxs),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSDimens.sizeXs,
              vertical: DSDimens.sizeXs,
            ),
            decoration: BoxDecoration(
              color: DSColors.surfaceCardDim,
              borderRadius: BorderRadius.circular(DSRadii.md),
            ),
            child: Row(
              children: [
                Expanded(child: Text(value, style: DSTextStyles.bodyLg)),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: DSColors.inkSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IntervalChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _IntervalChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: DSMotion.durFast,
        curve: DSMotion.curveStandard,
        padding: const EdgeInsets.symmetric(vertical: DSDimens.sizeXs),
        decoration: BoxDecoration(
          color: selected ? DSColors.tintBlueSoft : DSColors.surfaceCardDim,
          borderRadius: BorderRadius.circular(DSRadii.md),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: DSTextStyles.bodyLg.copyWith(
            color: selected ? DSColors.accentInfo : DSColors.inkSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

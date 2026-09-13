import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_vet_contact.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_protocol.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_date_format.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_labels.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/health_date_row.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/health_text_field.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/photo_source_sheet.dart';

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
///
/// [vet] prefills the vet and clinic fields from the cat's saved contact —
/// editable, since a one-off act may have happened elsewhere.
///
/// [onScanBooklet] adds a "scan the booklet" row at the top of the picker; the
/// sheet closes (returning null) before calling it, so the caller opens the
/// capture from the page, not from inside a dismissed sheet's context.
Future<HealthRecordDraft?> showAddHealthRecordSheet(
  BuildContext context, {
  CatVetContact? vet,
  VoidCallback? onScanBooklet,
}) {
  return showModalBottomSheet<HealthRecordDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _AddHealthRecordSheet(
      vet: vet,
      onScanBooklet: onScanBooklet,
    ),
  );
}

/// The sheet's answer: the record, and the photo to attach to it once it has
/// an id. Two values because the file is device state, not record data.
class HealthRecordDraft {
  final HealthEventEntity event;
  final File? attachment;

  const HealthRecordDraft({required this.event, this.attachment});
}

class _AddHealthRecordSheet extends StatefulWidget {
  final CatVetContact? vet;
  final VoidCallback? onScanBooklet;

  const _AddHealthRecordSheet({this.vet, this.onScanBooklet});

  @override
  State<_AddHealthRecordSheet> createState() => _AddHealthRecordSheetState();
}

class _AddHealthRecordSheetState extends State<_AddHealthRecordSheet> {
  HealthProtocol? _protocol;
  HealthCategory? _freeformCategory;
  bool _picked = false;

  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  late final _vetController =
      TextEditingController(text: widget.vet?.name ?? '');
  late final _clinicController =
      TextEditingController(text: widget.vet?.clinic ?? '');
  final _weightController = TextEditingController();
  final _courseDaysController = TextEditingController();
  final _dosesPerDayController = TextEditingController();

  DateTime _date = DateTime.now();
  File? _attachment;
  final _imagePicker = ImagePicker();

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
    _courseDaysController.dispose();
    _dosesPerDayController.dispose();
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
          if (widget.onScanBooklet case final scan?) ...[
            DSOptionRow(
              label: l10n.healthBookletPickerRow,
              description: l10n.healthBookletPickerRowDesc,
              leadingIcon: Icons.document_scanner_outlined,
              onTap: () {
                Navigator.of(context).pop();
                scan();
              },
            ),
            const SizedBox(height: DSDimens.sizeS),
          ],
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
            HealthTextField(
              label: l10n.healthAddFieldTitleLabel,
              controller: _titleController,
              hint: l10n.healthAddFieldTitleHint,
              errorText: _titleMissing ? l10n.healthAddTitleRequired : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: DSDimens.sizeS),
          ],

          HealthDateRow(
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

          // A medication course: how long, how often. Only offered on a
          // freeform treatment — protocols have their own cadence.
          if (isFreeform && _freeformCategory == HealthCategory.treatment) ...[
            Row(
              children: [
                Expanded(
                  child: HealthTextField(
                    label: l10n.healthAddFieldCourseDaysLabel,
                    controller: _courseDaysController,
                    hint: l10n.healthAddFieldCourseDaysHint,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: DSDimens.sizeXs),
                Expanded(
                  child: HealthTextField(
                    label: l10n.healthAddFieldDosesPerDayLabel,
                    controller: _dosesPerDayController,
                    hint: l10n.healthAddFieldDosesPerDayHint,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSDimens.sizeS),
          ],
          HealthTextField(
            label: l10n.healthAddFieldWeightLabel,
            controller: _weightController,
            hint: l10n.healthAddFieldWeightHint,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
          ),
          const SizedBox(height: DSDimens.sizeS),
          HealthTextField(
            label: l10n.healthAddFieldNotesLabel,
            controller: _notesController,
            hint: l10n.healthAddFieldNotesHint,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: DSDimens.sizeS),
          _PhotoRow(
            attachment: _attachment,
            onAdd: _pickAttachment,
            onRemove: () => setState(() => _attachment = null),
          ),
          const SizedBox(height: DSDimens.sizeS),
          Row(
            children: [
              Expanded(
                child: HealthTextField(
                  label: l10n.healthAddFieldVetLabel,
                  controller: _vetController,
                  hint: l10n.healthAddFieldVetHint,
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: DSDimens.sizeXs),
              Expanded(
                child: HealthTextField(
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

  Future<void> _pickAttachment() async {
    final file = await pickPhotoFromSheet(context, _imagePicker);
    if (!mounted || file == null) return;
    setState(() => _attachment = file);
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
    // A 7-day course started on Monday ends on Sunday: end = start + days − 1.
    final isTreatment =
        protocol == null && _freeformCategory == HealthCategory.treatment;
    final courseDays =
        isTreatment ? int.tryParse(_courseDaysController.text.trim()) : null;
    final courseEndAt = courseDays == null || courseDays < 1
        ? null
        : _date.add(Duration(days: courseDays - 1));
    final dosesPerDay = courseEndAt == null
        ? null
        : int.tryParse(_dosesPerDayController.text.trim());

    Navigator.of(context).pop(
      HealthRecordDraft(
        event: HealthEventEntity(
          protocolId: protocol?.id,
          category:
              protocol?.category ?? _freeformCategory ?? HealthCategory.other,
          title: protocol == null ? title : '',
          notes: _emptyToNull(_notesController.text),
          status: HealthEventStatus.done,
          performedAt: _date,
          intervalDays: protocol?.id == 'rabies' ? _rabiesIntervalDays : null,
          weightKg: weight,
          vetName: _emptyToNull(_vetController.text),
          clinic: _emptyToNull(_clinicController.text),
          courseEndAt: courseEndAt,
          dosesPerDay: dosesPerDay != null && dosesPerDay > 0 ? dosesPerDay : null,
        ),
        attachment: _attachment,
      ),
    );
  }

  static String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
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

/// "Add a photo" — a booklet page or a lab result — or the picked file's
/// thumbnail with a remove link.
class _PhotoRow extends StatelessWidget {
  final File? attachment;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _PhotoRow({
    required this.attachment,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final file = attachment;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.healthAddPhotoLabel, style: DSTextStyles.label),
        const SizedBox(height: DSDimens.sizeXxs),
        if (file == null)
          GestureDetector(
            onTap: onAdd,
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
                  const Icon(
                    Icons.add_a_photo_outlined,
                    size: 20,
                    color: DSColors.inkSecondary,
                  ),
                  const SizedBox(width: DSDimens.sizeXs),
                  Expanded(
                    child: Text(
                      l10n.healthAddPhotoHint,
                      style: DSTextStyles.bodyMd.copyWith(
                        color: DSColors.inkTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(DSRadii.md),
                child: Image.file(
                  file,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: DSDimens.sizeS),
              DSTextLink(label: l10n.healthAddPhotoRemove, onPressed: onRemove),
            ],
          ),
      ],
    );
  }
}

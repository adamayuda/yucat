import 'package:flutter/material.dart';
import 'package:mixpanel_flutter_session_replay/mixpanel_flutter_session_replay.dart'
    show MixpanelMask;
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_vet_contact.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/health_text_field.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// "Your vet" — name, clinic, address and a one-tap call.
///
/// Sits under the allergies card on the Upcoming tab, same header-plus-card
/// shape. Everything the owner typed is wrapped in `MixpanelMask`: a vet's
/// name and phone number are the owner's data, not ours to replay.
class VetContactCard extends StatelessWidget {
  final CatVetContact? vet;
  final VoidCallback onEdit;
  final VoidCallback? onCall;

  const VetContactCard({
    super.key,
    required this.vet,
    required this.onEdit,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vet = this.vet;
    final phone = vet?.phone?.trim();
    final hasPhone = phone != null && phone.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.healthVetTitle, style: DSTextStyles.titleMd),
            ),
            DSTextLink(
              label: vet == null ? l10n.healthVetAdd : l10n.healthVetEdit,
              onPressed: onEdit,
            ),
          ],
        ),
        const SizedBox(height: DSDimens.sizeXxs),
        DSCard(
          padding: const EdgeInsets.all(DSDimens.sizeS),
          child: vet == null
              ? Text(l10n.healthVetEmpty, style: DSTextStyles.bodyMd)
              : Row(
                  children: [
                    Expanded(
                      child: MixpanelMask(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vet.displayName,
                              style: DSTextStyles.titleMd,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            for (final line in _detailLines(vet)) ...[
                              const SizedBox(height: DSDimens.sizeXxxs),
                              Text(
                                line,
                                style: DSTextStyles.bodyMd.copyWith(
                                  color: DSColors.inkSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (hasPhone && onCall != null) ...[
                      const SizedBox(width: DSDimens.sizeXs),
                      _CallButton(label: l10n.healthVetCall, onTap: onCall!),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  /// Clinic (when it isn't already the headline), address, phone.
  List<String> _detailLines(CatVetContact vet) {
    final lines = <String>[];
    final clinic = vet.clinic?.trim();
    if (clinic != null && clinic.isNotEmpty && clinic != vet.displayName) {
      lines.add(clinic);
    }
    final address = vet.address?.trim();
    if (address != null && address.isNotEmpty) lines.add(address);
    final phone = vet.phone?.trim();
    if (phone != null && phone.isNotEmpty) lines.add(phone);
    return lines;
  }
}

class _CallButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CallButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: DSColors.accentSuccessSoft,
            borderRadius: BorderRadius.circular(DSRadii.pill),
          ),
          child: const Icon(
            Icons.call_rounded,
            size: 22,
            color: DSColors.accentSuccess,
          ),
        ),
      ),
    );
  }
}

/// Edit sheet. Returns the contact to save, an **empty** contact for
/// "remove" (see `CatVetContact.isEmpty`), or null when dismissed.
Future<CatVetContact?> showVetContactSheet(
  BuildContext context, {
  CatVetContact? initial,
}) {
  return showModalBottomSheet<CatVetContact>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _VetContactSheet(initial: initial),
  );
}

class _VetContactSheet extends StatefulWidget {
  final CatVetContact? initial;

  const _VetContactSheet({required this.initial});

  @override
  State<_VetContactSheet> createState() => _VetContactSheetState();
}

class _VetContactSheetState extends State<_VetContactSheet> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _clinic =
      TextEditingController(text: widget.initial?.clinic ?? '');
  late final _phone = TextEditingController(text: widget.initial?.phone ?? '');
  late final _address =
      TextEditingController(text: widget.initial?.address ?? '');
  bool _nameMissing = false;

  @override
  void dispose() {
    _name.dispose();
    _clinic.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  CatVetContact _draft() => CatVetContact(
        name: _name.text.trim(),
        clinic: _emptyToNull(_clinic.text),
        phone: _emptyToNull(_phone.text),
        address: _emptyToNull(_address.text),
      );

  void _save() {
    final draft = _draft();
    // A phone or address with no one to attach it to is a record nobody can
    // read back; ask for a name or a clinic. Everything blank is a removal.
    if (draft.isEmpty) {
      Navigator.of(context).pop(draft);
      return;
    }
    if (draft.displayName.isEmpty) {
      setState(() => _nameMissing = true);
      return;
    }
    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    DSDimens.sizeL,
                    DSDimens.sizeL,
                    DSDimens.sizeL,
                    DSDimens.sizeS,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.healthVetTitle, style: DSTextStyles.titleMd),
                      const SizedBox(height: DSDimens.sizeS),
                      HealthTextField(
                        label: l10n.healthVetFieldName,
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        errorText:
                            _nameMissing ? l10n.healthVetNameRequired : null,
                      ),
                      const SizedBox(height: DSDimens.sizeS),
                      HealthTextField(
                        label: l10n.healthVetFieldClinic,
                        controller: _clinic,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: DSDimens.sizeS),
                      HealthTextField(
                        label: l10n.healthVetFieldPhone,
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: DSDimens.sizeS),
                      HealthTextField(
                        label: l10n.healthVetFieldAddress,
                        controller: _address,
                        maxLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSDimens.sizeL,
                  DSDimens.sizeXxs,
                  DSDimens.sizeL,
                  DSDimens.sizeS,
                ),
                child: Column(
                  children: [
                    DSPillButton(
                      label: l10n.healthVetSave,
                      showChevron: false,
                      onPressed: _save,
                    ),
                    if (widget.initial != null) ...[
                      const SizedBox(height: DSDimens.sizeXs),
                      DSTextLink(
                        label: l10n.healthVetRemove,
                        onPressed: () => Navigator.of(context)
                            .pop(const CatVetContact(name: '')),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

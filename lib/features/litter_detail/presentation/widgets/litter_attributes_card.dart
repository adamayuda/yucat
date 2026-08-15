import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/litter_detail/presentation/utils/litter_additive_labels.dart';
import 'package:yucat/features/litter_detail/presentation/utils/litter_attribute_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// The litter's factual attributes, as tone-coded pills.
///
/// This is litter's answer to the nutrition grid: it replaces macros the
/// category simply does not have. Attributes the backend could not establish
/// contribute no pill at all — see `litterAttributes`.
class LitterAttributesCard extends StatelessWidget {
  final LitterDisplayModel litter;

  const LitterAttributesCard({super.key, required this.litter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final attributes = litterAttributes(litter, l10n);
    final additives = litter.additives;

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.litterDetailAttributesTitle,
            style: DSTextStyles.titleMd,
          ),
          const SizedBox(height: DSDimens.sizeS),
          Wrap(
            spacing: DSDimens.sizeXxs,
            runSpacing: DSDimens.sizeXxs,
            children: [
              for (final attribute in attributes)
                _AttributePill(attribute: attribute),
            ],
          ),
          if (additives.isNotEmpty) ...[
            const SizedBox(height: DSDimens.sizeS),
            Text(
              l10n.litterDetailAdditives,
              style: DSTextStyles.caption.copyWith(
                color: DSColors.inkSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: DSDimens.sizeXxxs),
            Text(
              additives.map((a) => litterAdditiveLabel(a, l10n)).join(' · '),
              style: DSTextStyles.bodyMd,
            ),
          ],
        ],
      ),
    );
  }
}

class _AttributePill extends StatelessWidget {
  final LitterAttribute attribute;

  const _AttributePill({required this.attribute});

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (attribute.tone) {
      LitterAttributeTone.positive => (
          DSColors.accentSuccessSoft,
          DSColors.accentSuccess,
        ),
      LitterAttributeTone.negative => (
          const Color(0xFFFFF3D6),
          const Color(0xFFB37800),
        ),
      LitterAttributeTone.neutral => (
          DSColors.tintSky,
          DSColors.inkPrimary,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXs,
        vertical: DSDimens.sizeXxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Text(
        attribute.label,
        style: DSTextStyles.caption.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

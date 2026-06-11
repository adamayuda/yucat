import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// Profile snapshot for the active cat — reinforces that scores are
/// personalized. Tapping opens the cat's detail page.
class ActiveCatSnapshotCard extends StatelessWidget {
  final CatEntity cat;
  final VoidCallback onTap;

  const ActiveCatSnapshotCard({
    super.key,
    required this.cat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tags = _tags(cat, l10n);
    final conditions = cat.healthConditions ?? const [];

    return DSCard(
      onTap: onTap,
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CatAvatar(photoUrl: cat.profileImageUrl, size: 48),
              const SizedBox(width: DSDimens.sizeS),
              Expanded(
                child: Text(cat.name, style: DSTextStyles.titleMd),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: DSColors.inkTertiary,
                size: 24,
              ),
            ],
          ),
          if (tags.isNotEmpty || conditions.isNotEmpty) ...[
            const SizedBox(height: DSDimens.sizeS),
            Wrap(
              spacing: DSDimens.sizeXxs,
              runSpacing: DSDimens.sizeXxs,
              children: [
                for (final t in tags) _SnapshotPill(label: t),
                if (conditions.isNotEmpty)
                  _SnapshotPill(
                    label: l10n.homeCatConditionCount(conditions.length),
                    icon: Icons.warning_amber_rounded,
                    background: const Color(0xFFFCE4E1),
                    foreground: DSColors.accentDanger,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<String> _tags(CatEntity cat, AppLocalizations l10n) {
    final tags = <String>[];
    final age = _formatAgeGroup(cat.ageGroup, l10n);
    if (age != null) tags.add(age);
    final weight = _formatWeightCategory(cat.weightCategory, l10n);
    if (weight != null) tags.add(weight);
    if (cat.breed != null && cat.breed!.isNotEmpty) tags.add(cat.breed!);
    return tags;
  }

  String? _formatAgeGroup(String? ageGroup, AppLocalizations l10n) {
    if (ageGroup == null) return null;
    return switch (ageGroup.toLowerCase()) {
      'kitten' => l10n.homeCatKitten,
      'adult' => l10n.homeCatAdult,
      'senior' => l10n.homeCatSenior,
      _ => ageGroup,
    };
  }

  String? _formatWeightCategory(String? category, AppLocalizations l10n) {
    if (category == null || category.isEmpty) return null;
    return switch (category.toLowerCase()) {
      'underweight' => l10n.homeCatUnderweight,
      'normal' => l10n.homeCatHealthyWeight,
      'overweight' => l10n.homeCatOverweight,
      'obese' => l10n.homeCatObese,
      _ => category,
    };
  }
}

class _SnapshotPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;

  const _SnapshotPill({
    required this.label,
    this.icon,
    this.background = DSColors.tintLavender,
    this.foreground = DSColors.inkPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXs,
        vertical: DSDimens.sizeXxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: foreground, size: 14),
            const SizedBox(width: DSDimens.sizeXxxs),
          ],
          Text(
            label,
            style: DSTextStyles.caption.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

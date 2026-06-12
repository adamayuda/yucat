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
    final age = _formatAgeGroup(cat.ageGroup, l10n);
    final weight = _formatWeightCategory(cat.weightCategory, l10n);
    final breed =
        (cat.breed != null && cat.breed!.isNotEmpty) ? cat.breed : null;
    final conditions = cat.healthConditions ?? const [];

    // Onboarding-success-style summary rows (colored icon tile + label + value).
    final rows = <Widget>[
      if (age != null)
        _SummaryRow(
          icon: Icons.cake_rounded,
          tint: DSColors.tintMint,
          label: l10n.onboardingSuccessRowAge,
          value: age,
        ),
      if (weight != null)
        _SummaryRow(
          icon: Icons.monitor_weight_rounded,
          tint: DSColors.tintSand,
          label: l10n.onboardingSuccessRowBodyCondition,
          value: weight,
        ),
      if (breed != null)
        _SummaryRow(
          icon: Icons.pets_rounded,
          tint: DSColors.tintLavender,
          label: l10n.onboardingSuccessRowBreed,
          value: breed,
        ),
      _SummaryRow(
        icon: Icons.favorite_rounded,
        tint: DSColors.coralSurface,
        label: l10n.onboardingSuccessRowHealthConditions,
        value: conditions.isEmpty
            ? l10n.onboardingSuccessNone
            : l10n.homeCatConditionCount(conditions.length),
        danger: conditions.isNotEmpty,
      ),
    ];

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
          const SizedBox(height: DSDimens.sizeM),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: DSDimens.sizeM),
            rows[i],
          ],
        ],
      ),
    );
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

/// A colored icon tile + label + value row, matching the onboarding success
/// summary card.
class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String label;
  final String value;

  /// Renders the value in the danger colour (e.g. for active health conditions).
  final bool danger;

  const _SummaryRow({
    required this.icon,
    required this.tint,
    required this.label,
    required this.value,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(DSRadii.md),
          ),
          child: Icon(icon, size: 20, color: DSColors.inkPrimary),
        ),
        const SizedBox(width: DSDimens.sizeS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: DSTextStyles.caption.copyWith(
                  color: DSColors.inkTertiary,
                ),
              ),
              const SizedBox(height: DSDimens.sizeXxxxs),
              Text(
                value,
                style: DSTextStyles.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: danger ? DSColors.accentDanger : DSColors.inkPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

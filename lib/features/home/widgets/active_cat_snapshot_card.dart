import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// Profile snapshot for the active cat — reinforces that scores are
/// personalized. Lays the cat's attributes out two-per-row (mirroring the
/// onboarding success recap), with health conditions spanning the full width.
/// Tapping opens the cat's detail page.
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
    final notSet = l10n.onboardingSuccessNotSet;
    final conditions = cat.healthConditions ?? const [];

    // Six single-value facts, laid out two-per-row; health spans full width.
    final cells = <_SummaryCell>[
      _cell('Cake.svg', l10n.onboardingSuccessRowAge, _ageGroup(cat.ageGroup, l10n), notSet),
      _cell('Activity.svg', l10n.onboardingSuccessRowActivity, _activity(cat.activityLevel, l10n), notSet),
      _cell('Body condition.svg', l10n.onboardingSuccessRowBodyCondition, _weight(cat.weightCategory, l10n), notSet),
      _cell('Coat.svg', l10n.onboardingSuccessRowCoat, _coat(cat.coatType, l10n), notSet),
      _cell('Neuter status.svg', l10n.onboardingSuccessRowNeuterStatus, _neuter(cat.neuteredStatus, l10n), notSet),
      _cell('catwalk.svg', l10n.onboardingSuccessRowBreed, _breed(cat.breed), notSet),
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
          for (var i = 0; i < cells.length; i += 2) ...[
            if (i > 0) const SizedBox(height: DSDimens.sizeM),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cells[i]),
                const SizedBox(width: DSDimens.sizeS),
                Expanded(
                  child: i + 1 < cells.length
                      ? cells[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
          const SizedBox(height: DSDimens.sizeM),
          _SummaryCell(
            iconAsset: 'Health.svg',
            label: l10n.onboardingSuccessRowHealthConditions,
            value: conditions.isEmpty
                ? l10n.onboardingSuccessNone
                : l10n.homeCatConditionCount(conditions.length),
            valueMaxLines: 2,
            danger: conditions.isNotEmpty,
          ),
        ],
      ),
    );
  }

  _SummaryCell _cell(String icon, String label, String? value, String notSet) =>
      _SummaryCell(
        iconAsset: icon,
        label: label,
        value: value ?? notSet,
        muted: value == null,
      );

  String? _ageGroup(String? ageGroup, AppLocalizations l10n) {
    if (ageGroup == null) return null;
    return switch (ageGroup.toLowerCase()) {
      'kitten' => l10n.homeCatKitten,
      'adult' => l10n.homeCatAdult,
      'senior' => l10n.homeCatSenior,
      _ => ageGroup,
    };
  }

  String? _weight(String? category, AppLocalizations l10n) {
    if (category == null || category.isEmpty) return null;
    return switch (category.toLowerCase()) {
      'underweight' => l10n.homeCatUnderweight,
      'normal' => l10n.homeCatHealthyWeight,
      'overweight' => l10n.homeCatOverweight,
      'obese' => l10n.homeCatObese,
      _ => category,
    };
  }

  String? _activity(String? level, AppLocalizations l10n) {
    if (level == null || level.isEmpty) return null;
    return switch (level.toLowerCase()) {
      'low' => l10n.activityLowLabel,
      'medium' => l10n.activityMediumLabel,
      'high' => l10n.activityHighLabel,
      _ => level,
    };
  }

  String? _coat(String? coat, AppLocalizations l10n) {
    if (coat == null || coat.isEmpty) return null;
    return switch (coat.toLowerCase()) {
      'short_hair' => l10n.coatShortHair,
      'long_hair' => l10n.coatLongHair,
      'hairless' => l10n.coatHairless,
      _ => coat,
    };
  }

  String? _neuter(String? status, AppLocalizations l10n) {
    if (status == null || status.isEmpty) return null;
    return switch (status.toLowerCase()) {
      'neutered' => l10n.neuteredNeutered,
      'intact' => l10n.neuteredIntact,
      'pregnant' => l10n.neuteredPregnant,
      'lactating' => l10n.neuteredLactating,
      _ => status,
    };
  }

  String? _breed(String? breed) =>
      (breed != null && breed.isNotEmpty && breed != 'Other') ? breed : null;
}

/// A compact icon + label + value fact, sized to sit two-per-row in the
/// snapshot. Mirrors the onboarding success recap cell.
class _SummaryCell extends StatelessWidget {
  final String iconAsset;
  final String label;
  final String value;
  final bool muted;
  final bool danger;
  final int valueMaxLines;

  const _SummaryCell({
    required this.iconAsset,
    required this.label,
    required this.value,
    this.muted = false,
    this.danger = false,
    this.valueMaxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final Color valueColor = danger
        ? DSColors.accentDanger
        : muted
            ? DSColors.inkTertiary
            : DSColors.inkPrimary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset('assets/images/$iconAsset', width: 28, height: 28),
        const SizedBox(width: DSDimens.sizeXs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DSTextStyles.caption.copyWith(
                  color: DSColors.inkTertiary,
                ),
              ),
              const SizedBox(height: DSDimens.sizeXxxxs),
              Text(
                value,
                maxLines: valueMaxLines,
                overflow: TextOverflow.ellipsis,
                style: DSTextStyles.bodyLg.copyWith(
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

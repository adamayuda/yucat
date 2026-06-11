import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';

class CatHeroSection extends StatelessWidget {
  final CatModel cat;

  const CatHeroSection({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subtitle = _buildSubtitle(cat, l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CatAvatar(photoUrl: cat.profileImageUrl, size: 132),
        const SizedBox(height: DSDimens.sizeS),
        Text(
          cat.name,
          textAlign: TextAlign.center,
          style: DSTextStyles.displayLg,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: DSDimens.sizeXxxs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: DSTextStyles.bodyLg.copyWith(
              color: DSColors.inkSecondary,
            ),
          ),
        ],
      ],
    );
  }

  String? _buildSubtitle(CatModel cat, AppLocalizations l10n) {
    final parts = <String>[];
    final ageGroup = _formatAgeGroup(cat.ageGroup, l10n);
    if (ageGroup != null) parts.add(ageGroup);
    if (cat.breed != null && cat.breed!.isNotEmpty) parts.add(cat.breed!);
    if (parts.isEmpty) return null;
    return parts.join(' • ');
  }

  String? _formatAgeGroup(String? ageGroup, AppLocalizations l10n) {
    if (ageGroup == null) return null;
    return switch (ageGroup.toLowerCase()) {
      'kitten' => l10n.commonAgeGroupKitten,
      'adult' => l10n.commonAgeGroupAdult,
      'senior' => l10n.commonAgeGroupSenior,
      _ => ageGroup,
    };
  }
}

import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';

class CatHeroSection extends StatelessWidget {
  final CatModel cat;

  const CatHeroSection({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    final subtitle = _buildSubtitle(cat);
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

  String? _buildSubtitle(CatModel cat) {
    final parts = <String>[];
    final ageGroup = _formatAgeGroup(cat.ageGroup);
    if (ageGroup != null) parts.add(ageGroup);
    if (cat.breed != null && cat.breed!.isNotEmpty) parts.add(cat.breed!);
    if (parts.isEmpty) return null;
    return parts.join(' • ');
  }

  String? _formatAgeGroup(String? ageGroup) {
    if (ageGroup == null) return null;
    return switch (ageGroup.toLowerCase()) {
      'kitten' => 'Kitten',
      'adult' => 'Adult',
      'senior' => 'Senior',
      _ => ageGroup,
    };
  }
}

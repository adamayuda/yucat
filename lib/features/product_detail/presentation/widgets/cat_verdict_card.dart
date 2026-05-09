import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/cat_product_assessment.dart';
import 'package:yucat/features/product_detail/presentation/utils/per_cat_score.dart';
import 'package:yucat/features/product_detail/presentation/widgets/ring_score.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';
import 'package:yucat/presentation/components/ds_card.dart';

class CatVerdictCard extends StatelessWidget {
  final CatEntity cat;
  final ProductDisplayModel product;

  const CatVerdictCard({super.key, required this.cat, required this.product});

  @override
  Widget build(BuildContext context) {
    final assessment = evaluateCatProduct(cat, product);
    final perCat = derivePerCatScore(assessment);
    final findings = assessment.pros;

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CatAvatar(photoUrl: cat.profileImageUrl, size: 48),
              const SizedBox(width: DSDimens.sizeS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.name, style: DSTextStyles.titleMd),
                    if (_subtitle(cat) != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(cat)!,
                        style: DSTextStyles.bodyMd.copyWith(
                          color: DSColors.inkSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              RingScore(
                score: perCat.score,
                maxScore: perCat.maxScore,
                ratingColor: perCat.ratingColor,
                size: 56,
              ),
            ],
          ),
          if (findings.isEmpty) ...[
            const SizedBox(height: DSDimens.sizeS),
            Text(
              'No strong age-based pros for this cat.',
              style: DSTextStyles.bodyMd,
            ),
          ] else ...[
            const SizedBox(height: DSDimens.sizeS),
            for (final finding in findings)
              _FindingRow(text: finding),
          ],
        ],
      ),
    );
  }

  String? _subtitle(CatEntity cat) {
    final parts = <String>[];
    final age = _formatAgeGroup(cat.ageGroup);
    if (age != null) parts.add(age);
    if (cat.breed != null && cat.breed!.isNotEmpty) parts.add(cat.breed!);
    if (parts.isEmpty) return null;
    return parts.join(' · ');
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

class _FindingRow extends StatelessWidget {
  final String text;

  const _FindingRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: DSDimens.sizeXxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: DSColors.accentSuccessSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_rounded,
              color: DSColors.accentSuccess,
              size: 13,
            ),
          ),
          const SizedBox(width: DSDimens.sizeXs),
          Expanded(
            child: Text(
              text,
              style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

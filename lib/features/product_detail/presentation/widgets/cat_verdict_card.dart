import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/cat_product_assessment.dart';
import 'package:yucat/features/product_detail/presentation/utils/per_cat_score.dart';
import 'package:yucat/features/product_detail/presentation/widgets/ring_score.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';
import 'package:yucat/presentation/components/ds_card.dart';

// Order matches the dimension weights in cat_product_assessment.dart, so the
// most impactful findings always appear first in the verdict card.
const _dimensionOrder = [
  CatAssessmentDimension.health,
  CatAssessmentDimension.weight,
  CatAssessmentDimension.age,
  CatAssessmentDimension.activity,
  CatAssessmentDimension.neutered,
  CatAssessmentDimension.breed,
];

Map<CatAssessmentDimension, String> _dimensionLabels(AppLocalizations l10n) => {
  CatAssessmentDimension.health: l10n.productDetailDimHealth,
  CatAssessmentDimension.weight: l10n.productDetailDimWeight,
  CatAssessmentDimension.age: l10n.productDetailDimAge,
  CatAssessmentDimension.activity: l10n.productDetailDimActivity,
  CatAssessmentDimension.neutered: l10n.productDetailDimNeuteredStatus,
  CatAssessmentDimension.breed: l10n.productDetailDimBreed,
};

class CatVerdictCard extends StatelessWidget {
  final CatEntity cat;
  final ProductDisplayModel product;

  const CatVerdictCard({super.key, required this.cat, required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final assessment = evaluateCatProduct(cat, product, l10n);
    final perCat = derivePerCatScore(assessment);
    final hasFindings = assessment.pros.isNotEmpty || assessment.cons.isNotEmpty;

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
                    if (_subtitle(cat, l10n) != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(cat, l10n)!,
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
          if (!hasFindings) ...[
            const SizedBox(height: DSDimens.sizeS),
            Text(
              l10n.productDetailNeutralFit,
              style: DSTextStyles.bodyMd,
            ),
          ] else ...[
            const SizedBox(height: DSDimens.sizeS),
            ..._buildGroupedFindings(assessment, l10n),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildGroupedFindings(
      CatProductAssessment assessment, AppLocalizations l10n) {
    final widgets = <Widget>[];
    var firstGroup = true;

    for (final dim in _dimensionOrder) {
      final pros = assessment.pros.where((f) => f.dimension == dim).toList();
      final cons = assessment.cons.where((f) => f.dimension == dim).toList();
      if (pros.isEmpty && cons.isEmpty) continue;

      if (!firstGroup) {
        widgets.add(const SizedBox(height: DSDimens.sizeS));
      }
      firstGroup = false;

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: DSDimens.sizeXxxs),
          child: Text(
            _dimensionLabels(l10n)[dim]!,
            style: DSTextStyles.caption.copyWith(
              color: DSColors.inkSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
      for (final p in pros) {
        widgets.add(_FindingRow.success(text: p.text));
      }
      for (final c in cons) {
        widgets.add(_FindingRow.caution(text: c.text));
      }
    }

    return widgets;
  }

  String? _subtitle(CatEntity cat, AppLocalizations l10n) {
    final parts = <String>[];
    final age = _formatAgeGroup(cat.ageGroup, l10n);
    if (age != null) parts.add(age);
    if (cat.breed != null && cat.breed!.isNotEmpty) parts.add(cat.breed!);
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  String? _formatAgeGroup(String? ageGroup, AppLocalizations l10n) {
    if (ageGroup == null) return null;
    return switch (ageGroup.toLowerCase()) {
      'kitten' => l10n.productDetailAgeGroupKitten,
      'adult' => l10n.productDetailAgeGroupAdult,
      'senior' => l10n.productDetailAgeGroupSenior,
      _ => ageGroup,
    };
  }
}

enum _FindingKind { success, caution }

class _FindingRow extends StatelessWidget {
  final String text;
  final _FindingKind kind;

  const _FindingRow.success({required this.text}) : kind = _FindingKind.success;
  const _FindingRow.caution({required this.text}) : kind = _FindingKind.caution;

  @override
  Widget build(BuildContext context) {
    final isSuccess = kind == _FindingKind.success;
    final bg =
        isSuccess ? DSColors.accentSuccessSoft : const Color(0xFFFFF3D6);
    final fg =
        isSuccess ? DSColors.accentSuccess : const Color(0xFFB37800);
    final icon = isSuccess ? Icons.check_rounded : Icons.warning_amber_rounded;

    return Padding(
      padding: const EdgeInsets.only(top: DSDimens.sizeXxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, color: fg, size: 13),
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

import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';
import 'package:yucat/presentation/components/ds_card.dart';

class CatSummaryCard extends StatelessWidget {
  final CatModel cat;
  final VoidCallback onTap;

  const CatSummaryCard({super.key, required this.cat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DSCard(
      onTap: onTap,
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Row(
        children: [
          CatAvatar(photoUrl: cat.profileImageUrl),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat.name, style: DSTextStyles.titleMd),
                const SizedBox(height: DSDimens.sizeXxxs),
                Text(
                  _subtitle(cat),
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                ),
                if (cat.healthConditions != null &&
                    cat.healthConditions!.isNotEmpty) ...[
                  const SizedBox(height: DSDimens.sizeXxs),
                  _ConditionsPill(count: cat.healthConditions!.length),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: DSColors.inkTertiary,
            size: 24,
          ),
        ],
      ),
    );
  }

  String _subtitle(CatModel cat) {
    final parts = <String>[];
    final ageGroup = _formatAgeGroup(cat.ageGroup);
    if (ageGroup != null) parts.add(ageGroup);
    if (cat.breed != null && cat.breed!.isNotEmpty) parts.add(cat.breed!);
    if (parts.isEmpty) return 'Cat';
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

class _ConditionsPill extends StatelessWidget {
  final int count;

  const _ConditionsPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXxs,
        vertical: DSDimens.sizeXxxs,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4E1),
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: DSColors.accentDanger,
            size: 14,
          ),
          const SizedBox(width: DSDimens.sizeXxxs),
          Text(
            '$count condition${count == 1 ? '' : 's'}',
            style: DSTextStyles.caption.copyWith(
              color: DSColors.accentDanger,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

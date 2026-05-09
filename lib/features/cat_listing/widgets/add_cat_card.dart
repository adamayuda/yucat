import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_card.dart';

class AddCatCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddCatCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DSCard(
      onTap: onTap,
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: DSColors.tintMint,
              borderRadius: BorderRadius.circular(DSRadii.pill),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.add_rounded,
              color: DSColors.accentSuccess,
              size: 28,
            ),
          ),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add another cat', style: DSTextStyles.titleMd),
                const SizedBox(height: DSDimens.sizeXxxs),
                Text(
                  'Create a new profile',
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                ),
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
}

import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// Soft cream advisory card — a lightbulb disc beside a titled note.
///
/// Used to close a detail screen with the one thing worth remembering: a recipe's
/// serving caveat, a food's frequency limit. The caller supplies [title] because
/// each surface labels it differently ("Tip", "YuCat tip").
class DSTipCard extends StatelessWidget {
  final String title;
  final String body;

  const DSTipCard({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return DSCard(
      background: DSColors.tintCream,
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DSColors.surfaceCard.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: DSColors.coralAccent,
              size: 18,
            ),
          ),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: DSTextStyles.titleMd),
                const SizedBox(height: DSDimens.sizeXxxs),
                Text(
                  body,
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

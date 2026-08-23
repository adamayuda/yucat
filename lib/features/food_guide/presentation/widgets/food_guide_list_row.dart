import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/food_guide/presentation/models/food_guide_display_model.dart';
import 'package:yucat/features/food_guide/presentation/widgets/food_guide_labels.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// One row of the food-guide list: photo, name, safety pill, chevron.
///
/// No description, unlike `RecipeRowCard` — the photo and the pill say enough
/// at list level, and the full copy is one tap away.
class FoodGuideListRow extends StatelessWidget {
  final FoodGuideDisplayModel item;
  final VoidCallback onTap;

  const FoodGuideListRow({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DSCard(
      onTap: onTap,
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Row(
        children: [
          _Thumb(imageUrl: item.imageUrl, emoji: item.emoji),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: DSTextStyles.titleMd,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: DSDimens.sizeXxs),
                FoodSafetyPill(safety: item.safety),
              ],
            ),
          ),
          const SizedBox(width: DSDimens.sizeXxs),
          const Icon(
            Icons.chevron_right,
            color: DSColors.inkTertiary,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? imageUrl;
  final String emoji;

  const _Thumb({required this.imageUrl, required this.emoji});

  static const double _size = 64;

  @override
  Widget build(BuildContext context) {
    // Check for a URL first so an entry with no photo never starts a network
    // request; the tint sits behind the image so there's no white flash.
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: DSColors.tintLavender,
        borderRadius: BorderRadius.circular(DSRadii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              width: _size,
              height: _size,
              errorBuilder: (_, __, ___) =>
                  FoodGuideEmoji(emoji: emoji, size: 28),
            )
          : FoodGuideEmoji(emoji: emoji, size: 28),
    );
  }
}

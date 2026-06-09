import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';

/// Compact greeting at the top of Home. Shows the active cat's avatar and a
/// personalized prompt, or generic copy when the user has no cats.
class HomeHeader extends StatelessWidget {
  final CatEntity? activeCat;

  const HomeHeader({super.key, this.activeCat});

  @override
  Widget build(BuildContext context) {
    final cat = activeCat;
    final subtitle = cat != null
        ? 'Ready to find food for ${cat.name}?'
        : 'Ready to scan a product?';

    return Row(
      children: [
        CatAvatar(photoUrl: cat?.profileImageUrl, size: 48),
        const SizedBox(width: DSDimens.sizeS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cat != null ? 'Hey 👋' : 'Welcome', style: DSTextStyles.headlineMd),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

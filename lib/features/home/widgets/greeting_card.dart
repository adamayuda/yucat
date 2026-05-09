import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';
import 'package:yucat/presentation/components/ds_card.dart';

class GreetingCard extends StatelessWidget {
  final String? primaryCatName;
  final String? primaryCatPhotoUrl;

  const GreetingCard({
    super.key,
    this.primaryCatName,
    this.primaryCatPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasCat = primaryCatName != null && primaryCatName!.isNotEmpty;
    final headline = hasCat ? 'Hey 👋' : 'Welcome';
    final subline = hasCat
        ? 'Ready to find food for $primaryCatName?'
        : 'Ready to scan a product?';

    return DSCard(
      child: Row(
        children: [
          CatAvatar(photoUrl: primaryCatPhotoUrl),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline, style: DSTextStyles.headlineMd),
                const SizedBox(height: DSDimens.sizeXxxs),
                Text(
                  subline,
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

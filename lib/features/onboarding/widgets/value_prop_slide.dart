import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class ValuePropSlide extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final Color tint;

  const ValuePropSlide({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tint,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: DSColors.surfaceCard,
                borderRadius: BorderRadius.circular(DSRadii.xl),
                boxShadow: DSShadows.e2,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(image, fit: BoxFit.contain),
            ),
            const SizedBox(height: DSDimens.size3xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: DSTextStyles.displayLg,
            ),
            const SizedBox(height: DSDimens.sizeS),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DSDimens.sizeS,
              ),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: DSTextStyles.bodyLg.copyWith(
                  color: DSColors.inkSecondary,
                ),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

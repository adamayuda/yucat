import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/widgets/cat_verdict_card.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

class CatAssessmentSection extends StatelessWidget {
  final List<CatEntity> cats;
  final ProductDisplayModel product;
  final VoidCallback onCreateCat;

  const CatAssessmentSection({
    super.key,
    required this.cats,
    required this.product,
    required this.onCreateCat,
  });

  @override
  Widget build(BuildContext context) {
    if (cats.isEmpty) {
      return DSCard(
        padding: const EdgeInsets.all(DSDimens.sizeL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My cat's score", style: DSTextStyles.titleMd),
            const SizedBox(height: DSDimens.sizeXxs),
            Text(
              'Create a cat profile to see a personalized score for your cat.',
              style: DSTextStyles.bodyMd,
            ),
            const SizedBox(height: DSDimens.sizeS),
            DSPillButton(label: 'Add a cat', onPressed: onCreateCat),
          ],
        ),
      );
    }

    final verdictLabel =
        '${cats.length} ${cats.length == 1 ? 'VERDICT' : 'VERDICTS'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text('For your cats', style: DSTextStyles.displayLg),
            ),
            Text(
              verdictLabel,
              style: DSTextStyles.caption.copyWith(
                color: DSColors.inkSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSDimens.sizeS),
        for (var i = 0; i < cats.length; i++) ...[
          if (i > 0) const SizedBox(height: DSDimens.sizeS),
          CatVerdictCard(cat: cats[i], product: product),
        ],
      ],
    );
  }
}

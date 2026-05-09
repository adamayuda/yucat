import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// Shared empty/error placeholder. Centered illustration + optional headline +
/// body line + optional pill CTA. Use named constructors `DSStateView.error()`
/// and `DSStateView.empty()` for default illustrations and messaging.
class DSStateView extends StatelessWidget {
  final String illustrationAsset;
  final String? headline;
  final String body;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;
  final double illustrationSize;

  const DSStateView({
    super.key,
    required this.illustrationAsset,
    required this.body,
    this.headline,
    this.ctaLabel,
    this.onCtaPressed,
    this.illustrationSize = 200,
  });

  /// Default error layout: Error.gif + body + optional Try-again CTA.
  const DSStateView.error({
    super.key,
    required this.body,
    this.headline,
    this.ctaLabel = 'Try again',
    this.onCtaPressed,
    this.illustrationSize = 180,
  }) : illustrationAsset = 'assets/images/Illustrations/Error.gif';

  /// Default empty layout: requires illustrationAsset, body, and CTA.
  const DSStateView.empty({
    super.key,
    required this.illustrationAsset,
    required this.body,
    this.headline,
    this.ctaLabel,
    this.onCtaPressed,
    this.illustrationSize = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              illustrationAsset,
              width: illustrationSize,
              height: illustrationSize,
              fit: BoxFit.contain,
            ),
            if (headline != null) ...[
              const SizedBox(height: DSDimens.sizeS),
              Text(
                headline!,
                textAlign: TextAlign.center,
                style: DSTextStyles.displayLg,
              ),
            ],
            const SizedBox(height: DSDimens.sizeS),
            Text(
              body,
              textAlign: TextAlign.center,
              style: DSTextStyles.bodyLg.copyWith(
                color: DSColors.inkSecondary,
              ),
            ),
            if (ctaLabel != null && onCtaPressed != null) ...[
              const SizedBox(height: DSDimens.sizeL),
              DSPillButton(
                label: ctaLabel!,
                onPressed: onCtaPressed,
                showChevron: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/onboarding_floating_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

/// Step right after Welcome — scan demo card that lands the value-prop
/// before the survey starts.
class ScanDemoScreen extends StatelessWidget {
  final VoidCallback onNext;

  const ScanDemoScreen({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return OnboardingScaffold(
      background: DSColors.surfaceCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          // The PNG is a self-contained rounded card on a transparent
          // background (its own ~36/888 corner radius), so we render it
          // directly — no white fill / clip — and only cast a soft shadow
          // matching the image's corners.
          SizedBox(
            width: width * 0.74,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * 0.74 * 36 / 888),
                boxShadow: DSShadows.e2,
              ),
              child: AspectRatio(
                aspectRatio: 888 / 1032,
                child: Image.asset(
                  'assets/images/onboarding-scan.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: DSDimens.size3xl),
          Text(
            "Track\nwhat's inside",
            textAlign: TextAlign.center,
            style: DSTextStyles.title(48),
          ),
          const SizedBox(height: DSDimens.sizeS),
          Text(
            'Point your camera at any\ncat food and get a verdict',
            textAlign: TextAlign.center,
            style: DSTextStyles.bodyMd.copyWith(
              color: DSColors.inkSecondary,
            ),
          ),
          const Spacer(flex: 2),
          OnboardingFloatingButton(label: 'Next', onPressed: onNext),
        ],
      ),
    );
  }
}

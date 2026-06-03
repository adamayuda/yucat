import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/onboarding_floating_button.dart';

class WhyYucatScreen extends StatelessWidget {
  final VoidCallback onNext;

  const WhyYucatScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: const Color(0xFFCAD8FF),
      body: Stack(
        children: [
          // Stretch the gradient bg to fill the full screen width and height
          // (BoxFit.fill) so no Scaffold color peeks on any device aspect.
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding-5-bg.png',
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Clear the back chip overlaid by onboarding_page.dart.
                  const SizedBox(height: 48),
                  Text(
                    "Why YuCat's\nunique approach\nworks",
                    textAlign: TextAlign.center,
                    style: DSTextStyles.displayLg,
                  ),
                  const Spacer(),
                  // Self-contained PNG of the three rotated feature cards on a
                  // transparent background — rendered directly, no fill/clip.
                  SizedBox(
                    width: width * 0.82,
                    child: AspectRatio(
                      aspectRatio: 1027 / 1168,
                      child: Image.asset(
                        'assets/images/onboarding-cards.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const Spacer(),
                  OnboardingFloatingButton(label: "Let's go", onPressed: onNext),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

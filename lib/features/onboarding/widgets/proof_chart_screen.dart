import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/onboarding_floating_button.dart';

class ProofChartScreen extends StatelessWidget {
  final VoidCallback onNext;

  const ProofChartScreen({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: const Color(0xFFEFEEF5),
      body: Stack(
        children: [
          Positioned.fill(
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE3FFDD), Color(0xFFEFEEF5)],
                ),
              ),
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
                    'YuCat provides\nlong-term results',
                    textAlign: TextAlign.center,
                    style: DSTextStyles.displayLg,
                  ),
                  const Spacer(),
                  SvgPicture.asset(
                    'assets/images/onboarding-graph.svg',
                    width: width * 0.82,
                  ),
                  const Spacer(),
                  // TODO: replace placeholder stat with a real, cited figure.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSDimens.sizeS,
                      vertical: DSDimens.sizeS,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFEFE1),
                      borderRadius: BorderRadius.circular(DSRadii.lg),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/images/onboarding-arrow-up.svg',
                          width: 22,
                        ),
                        const SizedBox(width: DSDimens.sizeXs),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: DSTextStyles.bodyMd.copyWith(
                                color: DSColors.inkSecondary,
                              ),
                              children: const [
                                TextSpan(
                                  text: '76% YuCat users ',
                                  style: TextStyle(
                                    color: DSColors.inkPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      'find a better-fit food in under 2 weeks',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OnboardingFloatingButton(label: 'Next', onPressed: onNext),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

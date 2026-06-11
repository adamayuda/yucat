import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/onboarding_floating_button.dart';
import 'package:yucat/presentation/utils/localized_asset.dart';

class ProofChartScreen extends StatelessWidget {
  final VoidCallback onNext;

  const ProofChartScreen({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: DSColors.tintCloud,
      body: Stack(
        children: [
          Positioned.fill(
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: DSGradients.onboardingProofChart,
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
                    l10n.onboardingProofChartTitle,
                    textAlign: TextAlign.center,
                    style: DSTextStyles.displayLg,
                  ),
                  const Spacer(),
                  SvgPicture.asset(
                    localizedAssetPath(
                      context,
                      'assets/images/onboarding-graph',
                      'svg',
                      available: const {'en', 'es', 'fr', 'hu'},
                    ),
                    width: width * 0.82,
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSDimens.sizeS,
                      vertical: DSDimens.sizeS,
                    ),
                    decoration: BoxDecoration(
                      color: DSColors.tintMintSoft,
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
                              children: [
                                TextSpan(
                                  text: l10n.onboardingProofChartCalloutBold,
                                  style: const TextStyle(
                                    color: DSColors.inkPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: l10n.onboardingProofChartCalloutRest,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OnboardingFloatingButton(label: l10n.commonNext, onPressed: onNext),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

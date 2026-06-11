import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/onboarding_floating_button.dart';

class NutritionFactScreen extends StatelessWidget {
  final VoidCallback onNext;

  const NutritionFactScreen({super.key, required this.onNext});

  static final Uri _sourceUri = Uri.parse(
    'https://www.merckvetmanual.com/management-and-nutrition/'
    'nutrition-small-animals/nutritional-requirements-of-small-animals',
  );

  Future<void> _openSource(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      if (!await launchUrl(_sourceUri, mode: LaunchMode.inAppWebView)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.onboardingCouldNotOpenLink)),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.onboardingCouldNotOpenLink)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: DSColors.tintSkyBright,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Clear the back chip overlaid by onboarding_page.dart.
              const SizedBox(height: 48),
              const Spacer(flex: 1),
              Container(
                width: 168,
                height: 168,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: DSColors.tintBlueSoft,
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset('assets/images/meat-2.svg', width: 116),
              ),
              const SizedBox(height: DSDimens.size3xl),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: DSTextStyles.displayLg,
                  children: [
                    TextSpan(text: l10n.onboardingNutritionFactHeadlinePart1),
                    TextSpan(
                      text: l10n.onboardingNutritionFactHighlight,
                      style: DSTextStyles.displayLg.copyWith(
                        color: DSColors.accentInfo,
                      ),
                    ),
                    TextSpan(text: l10n.onboardingNutritionFactHeadlinePart2),
                  ],
                ),
              ),
              const SizedBox(height: DSDimens.sizeL),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
                child: Text(
                  l10n.onboardingNutritionFactBody,
                  textAlign: TextAlign.center,
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DSDimens.sizeL),
                decoration: BoxDecoration(
                  color: DSColors.tintBlueSoft,
                  borderRadius: BorderRadius.circular(DSRadii.xl),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: DSColors.surfaceCard,
                        borderRadius: BorderRadius.circular(DSRadii.md),
                      ),
                      child: SvgPicture.asset(
                        'assets/images/merck-manual-logo.svg',
                      ),
                    ),
                    const SizedBox(width: DSDimens.sizeXs),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: DSTextStyles.caption.copyWith(
                            color: DSColors.inkSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: l10n.onboardingMerckManualName,
                              style: const TextStyle(
                                color: DSColors.inkPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: l10n.onboardingMerckManualQuote,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DSDimens.sizeS),
              GestureDetector(
                onTap: () => _openSource(context),
                child: Text(
                  l10n.onboardingSourceLink,
                  style: DSTextStyles.caption.copyWith(
                    color: DSColors.inkTertiary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              OnboardingFloatingButton(label: l10n.onboardingLetsGo, onPressed: onNext),
            ],
          ),
        ),
      ),
    );
  }
}

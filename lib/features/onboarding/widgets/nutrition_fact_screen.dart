import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/onboarding_floating_button.dart';

class NutritionFactScreen extends StatelessWidget {
  final VoidCallback onNext;

  const NutritionFactScreen({
    super.key,
    required this.onNext,
  });

  static final Uri _sourceUri = Uri.parse(
    'https://www.merckvetmanual.com/management-and-nutrition/'
    'nutrition-small-animals/nutritional-requirements-of-small-animals',
  );

  Future<void> _openSource(BuildContext context) async {
    try {
      if (!await launchUrl(_sourceUri, mode: LaunchMode.inAppWebView)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open this link.')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open this link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFE),
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
                  color: Color(0xFFE7EEFA),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/images/meat.svg',
                  width: 116,
                ),
              ),
              const SizedBox(height: DSDimens.size3xl),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: DSTextStyles.displayLg,
                  children: [
                    const TextSpan(text: 'A kitten needs\n'),
                    TextSpan(
                      text: '2.5× more protein',
                      style: DSTextStyles.displayLg.copyWith(
                        color: DSColors.accentInfo,
                      ),
                    ),
                    const TextSpan(text: '\nthan a senior cat'),
                  ],
                ),
              ),
              const SizedBox(height: DSDimens.sizeL),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
                child: Text(
                  "Life stage, weight, activity and health conditions all change "
                  "what belongs in your cat's bowl.",
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
                  color: const Color(0xFFE7EEFA),
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
                          children: const [
                            TextSpan(
                              text: 'Merck Veterinary Manual ',
                              style: TextStyle(
                                color: DSColors.inkPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: "notes a cat's protein and amino-acid "
                                  'needs change with life stage — kittens '
                                  'require more protein than adults and are '
                                  'more sensitive to amino-acid balance.',
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
                  'Source of recommendations',
                  style: DSTextStyles.caption.copyWith(
                    color: DSColors.inkTertiary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              OnboardingFloatingButton(label: "Let's go", onPressed: onNext),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/core/legal_urls.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
  });

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: DSColors.tintSky,
      body: Stack(
        children: [
          // Full-bleed background gradient (carries the bottom blurred blobs).
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding-bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Kibble bowl (with its baked-in "310 Kcal" pill) bleeding off the
          // top edge, sitting in from the left.
          Positioned(
            top: -32,
            left: size.width * 0.08,
            child: Image.asset(
              'assets/images/onboarding-food.png',
              width: size.width * 0.46,
              fit: BoxFit.contain,
            ),
          ),

          // Cute cat illustration (hearts + "With Cute Cat" arrow baked in).
          Positioned(
            top: size.width * 0.20,
            right: -8,
            child: SvgPicture.asset(
              'assets/images/onboarding-with-cute-cat.svg',
              width: size.width * 0.58,
            ),
          ),

          // Headline + CTA stack.
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.30),
                  Text(
                    'Decode\nevery\ncat\nfood',
                    textAlign: TextAlign.center,
                    style: DSTextStyles.title(76),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: Align(
                      child: DSPillButton(
                        label: 'Get started',
                        onPressed: onGetStarted,
                        showChevron: false,
                        verticalPadding: DSDimens.sizeXs,
                      ),
                    ),
                  ),
                  const SizedBox(height: DSDimens.sizeXxs),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "By continuing you're accepting our\n",
                        ),
                        TextSpan(
                          text: 'Terms of Use',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _openUrl(kTermsUrl),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Notice',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _openUrl(kPrivacyUrl),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: DSTextStyles.caption,
                  ),
                  const SizedBox(height: DSDimens.sizeS),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

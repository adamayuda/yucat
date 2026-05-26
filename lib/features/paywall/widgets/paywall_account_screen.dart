import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// Account-creation handoff shown after a successful subscription.
///
/// MOCK ONLY — the sign-in buttons are inert. The app currently uses
/// anonymous Firebase auth; wiring real account creation means adding
/// Sign in with Apple + Google Sign-In and linking/migrating the
/// anonymous account.
// TODO(feature): wire Sign in with Apple + Google Sign-In + anon linking.
class PaywallAccountScreen extends StatelessWidget {
  const PaywallAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.tintLavender,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              Text(
                "Now let's\nsave your\nkitty's profile",
                textAlign: TextAlign.center,
                style: DSTextStyles.displayHero,
              ),
              const SizedBox(height: DSDimens.sizeS),
              Text(
                'Sync across devices.\nNever lose your scans.',
                textAlign: TextAlign.center,
                style: DSTextStyles.bodyLg.copyWith(
                  color: DSColors.inkSecondary,
                ),
              ),
              const SizedBox(height: DSDimens.size3xl),
              const Text('😻', style: TextStyle(fontSize: 130)),
              const Spacer(flex: 2),
              DSPillButton(
                label: 'Continue with Apple',
                leadingIcon: Icons.apple,
                showChevron: false,
                // TODO(feature): trigger Sign in with Apple.
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: DSDimens.sizeXs),
              DSPillButton(
                label: 'Continue with Google',
                variant: DSPillButtonVariant.secondary,
                showChevron: false,
                // TODO(feature): trigger Google Sign-In.
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: DSDimens.sizeXs),
              DSTextLink(
                label: 'Maybe later',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: DSDimens.sizeS),
            ],
          ),
        ),
      ),
    );
  }
}

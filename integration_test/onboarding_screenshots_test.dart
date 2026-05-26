// Screenshot integration test for the onboarding + cat-creation flow.
//
// Boots the real app, forces the onboarding route by resetting
// SharedPreferences, then walks all 20 screens (10 onboarding captures + 9
// cat-create wizard steps + the success screen), capturing one PNG per screen.
//
// Run with:
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/onboarding_screenshots_test.dart \
//     -d <simulator-id>
//
// PNGs land in screenshots/ at the repo root (written by the driver).

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/main.dart' as app;
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/wizard_step_shell.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // An empty prefs store has no 'onboarding_completed' key, so SplashBloc
    // routes to OnBoardingRoute. Must run before app.main() ->
    // initializeDependencies() -> SharedPreferences.getInstance().
    //
    // Fallback if this ever fails to take effect on a device build: instead do
    //   final prefs = await SharedPreferences.getInstance();
    //   await prefs.clear();
    //   await prefs.setBool('onboarding_completed', false);
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
    'captures onboarding + cat-create flow screenshots',
    (tester) async {
      // Lets real async work (Firebase init, navigation, image streams) run for
      // [d] of wall-clock time, then renders one frame. We never pumpAndSettle:
      // the onboarding GIFs animate forever and would hang it.
      Future<void> idle([
        Duration d = const Duration(milliseconds: 600),
      ]) async {
        await tester.runAsync(() => Future<void>.delayed(d));
        await tester.pump();
      }

      Future<void> shot(String name) async {
        await idle();
        await binding.takeScreenshot(name);
      }

      Future<void> tapPill(String label) async {
        await tester.tap(find.widgetWithText(DSPillButton, label));
        await idle();
      }

      // The wizard renders exactly one DSPillButton via WizardStepShell; scope
      // to it so the offstage onboarding page beneath the modal can't interfere.
      // Steps 7 & 8 float the button inside a Stack, hence warnIfMissed: false.
      Future<void> tapWizardPill(String label) async {
        await tester.tap(
          find.descendant(
            of: find.byType(WizardStepShell),
            matching: find.widgetWithText(DSPillButton, label),
          ),
          warnIfMissed: false,
        );
        await idle();
      }

      // --- Boot ---------------------------------------------------------------
      app.main();
      // Poll until the splash finishes routing into the onboarding welcome
      // screen (Firebase + RevenueCat init can take a few seconds on first run).
      for (var i = 0; i < 20; i++) {
        await idle(const Duration(seconds: 1));
        if (find
            .widgetWithText(DSPillButton, 'Get started')
            .evaluate()
            .isNotEmpty) {
          break;
        }
      }
      expect(
        find.widgetWithText(DSPillButton, 'Get started'),
        findsOneWidget,
        reason: 'Expected the onboarding WelcomeScreen after boot.',
      );
      if (Platform.isIOS) {
        // Required before takeScreenshot() can capture the iOS surface.
        await binding.convertFlutterSurfaceToImage();
      }
      // The cat-create submit reads the current Firebase user. Anonymous
      // sign-in normally only happens in HomeBloc, which the onboarding path
      // never reaches — so sign in here or the wizard submit silently fails.
      try {
        await tester.runAsync(() => FirebaseAuth.instance.signInAnonymously());
      } catch (_) {
        // Non-fatal: only the post-submit success screen needs a signed-in user.
      }
      await idle();

      // --- Onboarding ---------------------------------------------------------
      await shot('01-onboarding-welcome');
      await tapPill('Get started');

      await shot('02-onboarding-value-carousel-1');
      await tapPill('Next');

      await shot('03-onboarding-value-carousel-2');
      await tapPill('Next');

      await shot('04-onboarding-value-carousel-3');
      await tapPill('Continue');

      await shot('05-onboarding-attribution');
      await tester.tap(find.text('From influencer'));
      await idle();
      await tapPill('Next'); // footer label flips from "Skip" once selected

      await shot('06-onboarding-attribution-details');
      await tester.enterText(find.byType(TextField), 'Jackson Galaxy');
      await idle();
      await tapPill('Next'); // footer label flips from "No, skip" once typed

      await shot('07-onboarding-social-proof');
      await tapPill('Next');

      await shot('08-onboarding-why-yucat');
      await tapPill("Let's go");

      await shot('09-onboarding-domain-pitch');
      await tapPill("Let's go");

      await shot('10-onboarding-add-cat-intro');
      await tapPill('Add my cat'); // pushes CreateCatRoute (fullscreenDialog)

      // --- Cat-create wizard --------------------------------------------------
      await idle(const Duration(milliseconds: 800)); // route push transition
      expect(
        find.byKey(const ValueKey('step_0')),
        findsOneWidget,
        reason: 'Expected the cat-create wizard after tapping "Add my cat".',
      );

      await shot('11-cat-create-name');
      await tester.enterText(
        find.descendant(
          of: find.byKey(const ValueKey('step_0')),
          matching: find.byType(TextField),
        ),
        'Caramel', // name is required to advance past step 0
      );
      await idle();
      await tapWizardPill('Next'); // step 0 -> 1

      await shot('12-cat-create-photo'); // do NOT tap the photo area (opens picker)
      await tapWizardPill('Next'); // step 1 -> 2

      await shot('13-cat-create-gender');
      await tapWizardPill('Next'); // step 2 -> 3

      await shot('14-cat-create-age');
      await tapWizardPill('Next'); // step 3 -> 4

      await shot('15-cat-create-activity');
      await tapWizardPill('Next'); // step 4 -> 5

      await shot('16-cat-create-neutered-status');
      await tapWizardPill('Next'); // step 5 -> 6

      await shot('17-cat-create-coat');
      await tapWizardPill('Next'); // step 6 -> 7

      // Step 7 (health): nothing selected, so the CTA shows the alt label.
      await shot('18-cat-create-health-conditions');
      await tapWizardPill('None of these'); // step 7 -> 8

      // Step 8 (breed): last step, so the CTA is the final submit label.
      await shot('19-cat-create-breed');
      await tapWizardPill('Create profile'); // submit + pop back to onboarding

      // --- Success ------------------------------------------------------------
      await idle(const Duration(seconds: 4)); // Firestore write + maybePop()
      await shot('20-onboarding-success');
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

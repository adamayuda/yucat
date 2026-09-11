import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Whether this run should expose the QA tools — the Profile "Reset onboarding"
/// row and the paywall's escape hatch.
///
/// True in debug builds and on **TestFlight**, false on the App Store.
///
/// ⚠️ Read this instead of `kDebugMode` for anything a tester needs. TestFlight
/// builds are *release* builds, so `kDebugMode` is a compile-time `false` there
/// and the tools were being stripped out of exactly the build they existed for.
///
/// ⚠️ Valid only after [resolveBuildEnvironment] has completed. It is awaited in
/// `main()` before `runApp`, so by the time any widget builds this is final.
/// Before that it reads `kDebugMode`, which is the safe answer either way.
bool get kQaToolsEnabled => kDebugMode || _isTestFlight;

/// The paywall escape hatch specifically — **debug builds only**, never
/// TestFlight.
///
/// ⚠️ Deliberately narrower than [kQaToolsEnabled], and not a mistake to
/// "fix". App Review installs carry a `sandboxReceipt` too, so anything gated
/// on [kQaToolsEnabled] is visible to the reviewer. A button that walks past
/// the hard paywall is the one affordance where that matters: it reads as
/// exactly the beta/demo functionality App Store Review Guideline 2.2
/// prohibits, and it would let a reviewer reach the whole app without ever
/// seeing the purchase flow they are meant to assess.
///
/// The Profile "Reset onboarding" row stays on [kQaToolsEnabled] — a tester
/// needs it on TestFlight, and a reviewer finding it is harmless.
bool get kPaywallEscapeHatchEnabled => kDebugMode;

bool _isTestFlight = false;

const MethodChannel _channel = MethodChannel('com.adam.yucat/build_env');

/// Asks the platform whether this install came from TestFlight, once.
///
/// iOS names the app receipt `sandboxReceipt` for a TestFlight install and
/// `receipt` for an App Store one — see `ios/Runner/AppDelegate.swift`. That
/// distinction is only available at *runtime*, which is the whole point: the
/// TestFlight build is the same binary submitted for review, so a compile-time
/// flag would mean either shipping a binary nobody tested or shipping the QA
/// tools to real users.
///
/// Fails closed. Anything unexpected — a non-iOS platform, a missing handler on
/// an older build, a malformed reply — leaves this false, so production never
/// grows a debug affordance by accident.
Future<void> resolveBuildEnvironment() async {
  if (kDebugMode) return; // Already enabled; no need to cross the channel.
  if (!Platform.isIOS) return; // Android has no receipt equivalent.
  try {
    _isTestFlight = await _channel.invokeMethod<bool>('isTestFlight') ?? false;
  } catch (_) {
    _isTestFlight = false;
  }
}

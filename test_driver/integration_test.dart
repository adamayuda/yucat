import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver for the screenshot integration test.
///
/// Receives the bytes sent by `binding.takeScreenshot(name)` in
/// `integration_test/onboarding_screenshots_test.dart` and writes each one to
/// `screenshots/<name>.png` at the repo root.
///
/// Run with:
///   flutter drive \
///     --driver=test_driver/integration_test.dart \
///     --target=integration_test/onboarding_screenshots_test.dart \
///     -d SIMULATOR_ID
Future<void> main() async {
  final outputDir = Directory('screenshots');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  await integrationDriver(
    onScreenshot: (
      String name,
      List<int> bytes, [
      Map<String, Object?>? args,
    ]) async {
      File('${outputDir.path}/$name.png').writeAsBytesSync(bytes);
      return true;
    },
  );
}

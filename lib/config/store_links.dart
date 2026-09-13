import 'dart:io';

/// Public store listings, used wherever the app links to itself (share
/// sheets). The App Store id is the listing's, not the bundle id; the Play
/// URL is keyed by the Android application id.
class StoreLinks {
  StoreLinks._();

  static const appStore =
      'https://apps.apple.com/app/cat-food-scanner-yucat/id6755060185';
  static const playStore =
      'https://play.google.com/store/apps/details?id=com.adam.yucat';

  /// The listing for the platform the user is on — what a shared message
  /// should point at, since the recipient is most likely on the same one.
  static String get current => Platform.isAndroid ? playStore : appStore;
}

import 'package:firebase_auth/firebase_auth.dart';

class AuthFirebaseDataSource {
  /// Signs in anonymously.
  ///
  /// Deliberately rethrows. This used to catch `FirebaseAuthException` and only
  /// `debugPrint` it, so `network-request-failed`, `too-many-requests` and App
  /// Check rejections all returned *normally* — callers then read a null
  /// `currentUser` with no way to tell a failure from a cold start, and
  /// `CatCreateBloc` force-unwrapped it. Callers decide how to recover.
  Future<void> signInAnonymously() async {
    await FirebaseAuth.instance.signInAnonymously();
  }

  User? currentUser() => FirebaseAuth.instance.currentUser;

  /// Anonymous sessions live in the iOS Keychain and survive an uninstall, so
  /// this is the only way to become a genuinely new user on a test device.
  Future<void> signOut() => FirebaseAuth.instance.signOut();
}

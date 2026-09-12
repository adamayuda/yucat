import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<void> signInAnonymously();

  User? currentUser();

  /// Drop the current session so the next [signInAnonymously] mints a new uid.
  /// QA only — the app has no user-facing sign-out.
  Future<void> signOut();
}

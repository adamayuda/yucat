import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<void> signInAnonymously();

  User? currentUser();
}

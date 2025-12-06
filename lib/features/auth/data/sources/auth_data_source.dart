import 'package:firebase_auth/firebase_auth.dart';

class AuthFirebaseDataSource {
  Future<void> signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      print("error");
    }
  }

  User? currentUser() {
    try {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;

      return firebaseAuth.currentUser;
    } catch (e) {
      throw UnimplementedError();
    }
  }
}

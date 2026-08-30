import 'package:firebase_auth/firebase_auth.dart';
import 'package:yucat/features/auth/domain/repository/auth_repository.dart';

/// Thrown when no anonymous session could be established. Callers that cannot
/// proceed without a uid should let this surface rather than force-unwrapping —
/// the typed name is what makes the failure legible in analytics, where
/// `e.runtimeType` is reported as `error_type`.
class AuthUnavailableException implements Exception {
  final String? code;

  const AuthUnavailableException([this.code]);

  @override
  String toString() =>
      'AuthUnavailableException: no anonymous session available'
      '${code != null ? ' ($code)' : ''}';
}

/// Returns the current Firebase user, signing in anonymously first if there
/// isn't one.
///
/// Anonymous sign-in can fail silently at boot (offline cold start, App Check
/// rejection, rate limiting), and `SplashBloc` routes into onboarding either
/// way. Every screen that needs a uid must therefore be able to retry rather
/// than assume the session exists — this is the single implementation of that
/// retry, previously copy-pasted into `HomeBloc` and `SplashBloc` and simply
/// missing from `CatCreateBloc`, where the resulting `user!` was crashing ~20%
/// of cat creations.
class EnsureSignedInUsecase {
  final AuthRepository repository;

  EnsureSignedInUsecase({required this.repository});

  Future<User?> call() async {
    if (repository.currentUser() != null) return repository.currentUser();

    try {
      await repository.signInAnonymously();
    } on FirebaseAuthException catch (_) {
      // Fall through: the null return below is the caller's signal.
    }

    return repository.currentUser();
  }
}

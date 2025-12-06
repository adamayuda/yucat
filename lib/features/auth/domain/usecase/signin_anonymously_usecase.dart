import 'package:yucat/features/auth/domain/repository/auth_repository.dart';

class SigninAnonymouslyUsecase {
  final AuthRepository repository;

  SigninAnonymouslyUsecase({required this.repository});

  Future<void> call() async {
    await repository.signInAnonymously();
  }
}

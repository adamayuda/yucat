import 'package:firebase_auth/firebase_auth.dart';
import 'package:yucat/features/auth/domain/repository/auth_repository.dart';

class CurrentUserUsecase {
  final AuthRepository repository;

  CurrentUserUsecase({required this.repository});

  User? call() {
    return repository.currentUser();
  }
}

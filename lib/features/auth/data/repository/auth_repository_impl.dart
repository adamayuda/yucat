import 'package:yucat/features/auth/domain/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yucat/features/auth/data/sources/auth_data_source.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthFirebaseDataSource _dataSource;

  AuthRepositoryImpl({required AuthFirebaseDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<void> signInAnonymously() async {
    return await _dataSource.signInAnonymously();
  }

  @override
  User? currentUser() {
    return _dataSource.currentUser();
  }
}

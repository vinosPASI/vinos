import 'package:frontend_web/src/features/auth/domain/auth_repository.dart';
import 'package:frontend_web/src/features/auth/domain/user_model.dart';
import 'package:frontend_web/src/features/auth/data/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<UserModel> login(String email, String password) async {
    return await _datasource.login(email, password);
  }

  @override
  Future<void> logout() async {
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return null;
  }
}

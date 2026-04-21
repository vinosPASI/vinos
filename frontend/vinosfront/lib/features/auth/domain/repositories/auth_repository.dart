import 'package:vinosfront/features/auth/domain/entities/user_model.dart';

abstract class AuthRepository {
  Future<UserResponse> login(String email, String password);
}

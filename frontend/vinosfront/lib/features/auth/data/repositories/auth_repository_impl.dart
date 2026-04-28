import 'package:dio/dio.dart';
import '../../domain/entities/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl(this._dio);

  @override
  Future<UserResponse> login(String email, String password) async {
    final response = await _dio.post(
      '/v1/identity/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(response.data);
    } else {
      throw Exception('Error en autenticación: ${response.statusMessage}');
    }
  }

  @override
  Future<UserResponse> register(String email, String password, String name) async {
    final response = await _dio.post(
      '/v1/identity/register',
      data: {
        'email': email,
        'password': password,
        'name': name,
      },
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(response.data);
    } else {
      throw Exception('Error en registro: ${response.statusMessage}');
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioProvider);
  return AuthRepositoryImpl(dioClient.dio);
});

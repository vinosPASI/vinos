import 'package:dio/dio.dart';
import '../../../shared/utils/dio_client.dart';
import '../domain/user_model.dart';

class AuthDatasource {
  final Dio _dio = DioClient().dio;

  // Ejecuta el login contra el IdentityService
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/v1/identity/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return UserModel.fromJson(data, email);
      } else {
        throw Exception('Error al iniciar sesión: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('Error de red: $message');
    }
  }

  // Ejecuta el registro contra el IdentityService
  Future<UserModel> register(String email, String password, String name) async {
    try {
      final response = await _dio.post(
        '/v1/identity/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return UserModel.fromJson(data, email);
      } else {
        throw Exception('Error al registrar usuario: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('Error de red en registro: $message');
    }
  }
}

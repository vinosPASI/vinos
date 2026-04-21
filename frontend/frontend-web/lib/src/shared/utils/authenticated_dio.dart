import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_web/src/features/auth/presentation/providers/auth_provider.dart';
import 'dio_client.dart';

/// Provider que expone una instancia de Dio autenticada.
/// Inyecta automáticamente el header Authorization: Bearer <token>.
final authenticatedDioProvider = Provider<Dio>((ref) {
  final authState = ref.watch(authProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: DioClient.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // Interceptor para inyectar el token de autenticación
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = authState.user?.token;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  ));

  return dio;
});

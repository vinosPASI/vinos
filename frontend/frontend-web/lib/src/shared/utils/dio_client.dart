import 'package:dio/dio.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';

// Configuración del cliente HTTP con soporte para HTTP/2
class DioClient {
  static const String baseUrl = 'https://winery-api.stuko.dev';
  
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  DioClient() {
    _dio.httpClientAdapter = Http2Adapter(
      ConnectionManager(
        idleTimeout: const Duration(seconds: 15),
      ),
    );
  }

  Dio get dio => _dio;

  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();
}

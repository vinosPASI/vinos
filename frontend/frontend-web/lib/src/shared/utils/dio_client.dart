import 'package:dio/dio.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:flutter/foundation.dart';
class DioClient {
  static const String baseUrl = 'http://localhost:8080';
  
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 1800),
      receiveTimeout: const Duration(seconds: 1800),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  static final DioClient _instance = DioClient._internal();
  
  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    if (!kIsWeb) {
      _dio.httpClientAdapter = Http2Adapter(
        ConnectionManager(
          idleTimeout: const Duration(seconds: 15),
        ),
      );
    }
  }

  Dio get dio => _dio;
}

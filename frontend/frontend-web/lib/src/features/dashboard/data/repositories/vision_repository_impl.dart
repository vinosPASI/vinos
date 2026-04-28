import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/utils/authenticated_dio.dart';
import '../../../../shared/utils/storage_service.dart';
import '../../domain/models/dashboard_models.dart';
import '../../domain/repositories/vision_repository.dart';

class VisionRepositoryImpl implements VisionRepository {
  final Dio _dio;

  VisionRepositoryImpl(this._dio);

  @override
  Future<AnalyzeWineLabelResponse> analyzeLabel(String fileName, Uint8List bytes) async {
    // Paso 1: Subir la imagen al Storage
    final objectReference = await StorageService.uploadFile(fileName, bytes, _dio);

    // Paso 2: Llamar al VisionService para analizar la etiqueta
    final response = await _dio.post(
      '/v1/vision/analyze',
      data: {
        'image_reference': objectReference,
      },
    );

    if (response.statusCode == 200) {
      return AnalyzeWineLabelResponse.fromJson(response.data);
    } else {
      throw Exception('Error al analizar etiqueta: ${response.statusMessage}');
    }
  }
}

// Inyección de dependencias
final visionRepositoryProvider = Provider<VisionRepository>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return VisionRepositoryImpl(dio);
});

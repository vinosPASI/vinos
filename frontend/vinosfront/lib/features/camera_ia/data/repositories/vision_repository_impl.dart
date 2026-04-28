import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/storage_service.dart';
import '../../domain/entities/vision_models.dart';
import '../../domain/repositories/vision_repository.dart';

class VisionRepositoryImpl implements VisionRepository {
  final Dio _dio;
  final StorageService _storageService;

  VisionRepositoryImpl(this._dio, this._storageService);

  @override
  Future<AnalyzeWineLabelResponse> analyzeLabel(String fileName, Uint8List bytes) async {
    final objectReference = await _storageService.uploadFile(fileName, bytes);

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

final visionRepositoryProvider = Provider<VisionRepository>((ref) {
  final dioClient = ref.watch(dioProvider);
  final storageService = ref.watch(storageServiceProvider);
  return VisionRepositoryImpl(dioClient.dio, storageService);
});

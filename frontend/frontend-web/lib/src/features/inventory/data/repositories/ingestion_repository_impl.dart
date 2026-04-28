import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/utils/authenticated_dio.dart';
import '../../../../shared/utils/storage_service.dart';
import '../../domain/models/inventario_models.dart';
import '../../domain/repositories/ingestion_repository.dart';

class IngestionRepositoryImpl implements IngestionRepository {
  final Dio _dio;

  IngestionRepositoryImpl(this._dio);

  @override
  Future<TriggerDataImportResponse> importCSV(String fileName, Uint8List bytes, String entityType) async {
    // Paso 1: Subir el CSV al Storage
    final objectReference = await StorageService.uploadFile(fileName, bytes, _dio);

    // Paso 2: Disparar la ingesta con la referencia del archivo
    final response = await _dio.post(
      '/v1/ingestion/import',
      data: {
        'file_reference': objectReference,
        'entity_type': entityType,
      },
    );

    if (response.statusCode == 200) {
      return TriggerDataImportResponse.fromJson(response.data);
    } else {
      throw Exception('Error al importar datos: ${response.statusMessage}');
    }
  }
}

// Inyección de dependencias
final ingestionRepositoryProvider = Provider<IngestionRepository>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return IngestionRepositoryImpl(dio);
});

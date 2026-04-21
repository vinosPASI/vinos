import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../domain/ingestion_models.dart';
import '../domain/ingestion_repository.dart';

class IngestionRepositoryImpl implements IngestionRepository {
  final Dio _dio;

  IngestionRepositoryImpl(this._dio);

  @override
  Future<TriggerDataImportResponse> importCSV(String fileReference, String entityType) async {
    final response = await _dio.post(
      '/stuko.api.v1.ingestion.IngestionService/TriggerDataImport',
      data: {
        'file_reference': fileReference,
        'entity_type': entityType,
      },
    );

    if (response.statusCode == 200) {
      return TriggerDataImportResponse.fromJson(response.data);
    } else {
      throw Exception('Error en importación: ${response.statusMessage}');
    }
  }
}

final ingestionRepositoryProvider = Provider<IngestionRepository>((ref) {
  final dioClient = ref.watch(dioProvider);
  return IngestionRepositoryImpl(dioClient.dio);
});

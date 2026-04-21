import 'ingestion_models.dart';

abstract class IngestionRepository {
  Future<TriggerDataImportResponse> importCSV(String fileReference, String entityType);
}

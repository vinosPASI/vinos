import 'dart:typed_data';
import '../models/inventario_models.dart';

/// Interfaz del repositorio de Ingesta.
/// Orquesta: upload CSV → TriggerDataImport → resultado.
abstract class IngestionRepository {
  Future<TriggerDataImportResponse> importCSV(String fileName, Uint8List bytes, String entityType);
}

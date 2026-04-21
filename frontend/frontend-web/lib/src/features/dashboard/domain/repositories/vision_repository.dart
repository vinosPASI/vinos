import 'dart:typed_data';
import '../models/dashboard_models.dart';

/// Interfaz del repositorio de Visión.
/// Orquesta: upload de imagen → análisis OCR → datos estructurados del vino.
abstract class VisionRepository {
  Future<AnalyzeWineLabelResponse> analyzeLabel(String fileName, Uint8List bytes);
}

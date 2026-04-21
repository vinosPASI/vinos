import 'dart:typed_data';
import 'package:vinosfront/features/camera_ia/domain/entities/vision_models.dart';

abstract class VisionRepository {
  Future<AnalyzeWineLabelResponse> analyzeLabel(String fileName, Uint8List bytes);
}

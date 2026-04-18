import 'dart:typed_data';
import 'package:dio/dio.dart';

/// Servicio compartido para subir archivos al Storage backend.
/// Usado tanto por Vision (imágenes) como por Ingestion (CSVs).
class StorageService {
  /// Sube un archivo al bucket y retorna la referencia del objeto.
  /// Formato de retorno: "bucket/filename" (ej: "winery-uploads/123_abc.csv")
  static Future<String> uploadFile(String fileName, Uint8List bytes, Dio authedDio) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      ),
    });

    final response = await authedDio.post(
      '/v1/storage/upload',
      queryParameters: {'bucket': 'winery-uploads'},
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      // Respuesta: {"url":"http://minio:9000/winery-uploads/XXX.ext","bucket":"winery-uploads"}
      final String url = data['url'] ?? '';
      final String bucket = data['bucket'] ?? 'winery-uploads';

      // Extraer el filename de la URL de MinIO
      final uri = Uri.parse(url);
      final filename = uri.pathSegments.last;

      return '$bucket/$filename';
    } else {
      throw Exception('Error al subir archivo: ${response.statusMessage}');
    }
  }
}

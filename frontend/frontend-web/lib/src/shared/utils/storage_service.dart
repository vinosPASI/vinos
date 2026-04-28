import 'dart:typed_data';
import 'package:dio/dio.dart';

class StorageService {
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
      final String url = data['url'] ?? '';
      final String bucket = data['bucket'] ?? 'winery-uploads';

      final uri = Uri.parse(url);
      final filename = uri.pathSegments.last;

      return '$bucket/$filename';
    } else {
      throw Exception('Error al subir archivo: ${response.statusMessage}');
    }
  }
}

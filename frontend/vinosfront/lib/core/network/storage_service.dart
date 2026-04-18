import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_provider.dart';

class StorageService {
  final Dio _dio;

  StorageService(this._dio);

  Future<String> uploadFile(String fileName, Uint8List bytes) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      ),
    });

    final response = await _dio.post(
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

final storageServiceProvider = Provider<StorageService>((ref) {
  final dioClient = ref.watch(dioProvider);
  return StorageService(dioClient.dio);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/secure_storage_service.dart';
import 'dio_client.dart';

final dioProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DioClient(secureStorage);
});
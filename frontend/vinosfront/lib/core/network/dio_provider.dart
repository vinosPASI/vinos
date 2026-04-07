import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_client.dart';

final dioProvider = Provider<DioClient>((ref) {
  return DioClient();
});
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/entities/home_models.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final Dio _dio;

  HomeRepositoryImpl(this._dio);

  @override
  Future<CreateBottlingOrderResponse> simulateBottlingOrder(String wineId, int quantity) async {
    final response = await _dio.post(
      '/stuko.api.v1.production.ProductionService/CreateBottlingOrder',
      data: {
        'wine_id': wineId,
        'target_quantity': quantity,
        'unit_type': 'BOTELLA_750ML',
        'planned_date': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
    );

    if (response.statusCode == 200) {
      return CreateBottlingOrderResponse.fromJson(response.data);
    } else {
      throw Exception('Error simulando orden: ${response.statusMessage}');
    }
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final dioClient = ref.watch(dioProvider);
  return HomeRepositoryImpl(dioClient.dio);
});

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/utils/authenticated_dio.dart';
import '../../domain/models/dashboard_models.dart';
import '../../domain/repositories/production_repository.dart';

class ProductionRepositoryImpl implements ProductionRepository {
  final Dio _dio;

  ProductionRepositoryImpl(this._dio);

  @override
  Future<CreateBottlingOrderResponse> simulateStockout(
    String wineId,
    int quantity,
    String unitType,
    int plannedDate,
  ) async {
    final response = await _dio.post(
      '/v1/production/bottling-order',
      data: {
        'wine_id': wineId,
        'target_quantity': quantity,
        'unit_type': unitType,
        'planned_date': plannedDate,
      },
    );

    if (response.statusCode == 200) {
      return CreateBottlingOrderResponse.fromJson(response.data);
    } else {
      throw Exception('Error al simular stockout: ${response.statusMessage}');
    }
  }
}

// Inyección de dependencias
final productionRepositoryProvider = Provider<ProductionRepository>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return ProductionRepositoryImpl(dio);
});

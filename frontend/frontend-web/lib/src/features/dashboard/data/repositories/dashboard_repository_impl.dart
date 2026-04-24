import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/utils/authenticated_dio.dart';
import '../../domain/models/dashboard_models.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final Dio _dio;

  DashboardRepositoryImpl(this._dio);

  @override
  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _dio.get(
        '/v1/dashboard/stats',
      );

      if (response.statusCode == 200) {
        return DashboardStats.fromJson(response.data);
      } else {
        throw Exception('Error al obtener KPIs del dashboard: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  @override
  Future<List<HoldingItem>> getHighValueHoldings() async {
    try {
      final response = await _dio.post(
        '/v1/dashboard/high-value-holdings',
        data: {},
      );

      if (response.statusCode == 200) {
        final List<dynamic> itemsData = response.data['items'] ?? [];
        return itemsData.map((item) => HoldingItem.fromJson(item)).toList();
      } else {
        throw Exception('Error al obtener activos de alto valor: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  @override
  Future<List<ExposureCategory>> getMarketExposureData() async {
    try {
      final response = await _dio.post(
        '/v1/dashboard/market-exposure',
        data: {},
      );

      if (response.statusCode == 200) {
        final List<dynamic> categoriesData = response.data['categories'] ?? [];
        return categoriesData.map((item) => ExposureCategory.fromJson(item)).toList();
      } else {
        throw Exception('Error al obtener datos de exposición: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  @override
  Future<List<ForecastingAlert>> getForecastingFeed() async {
    try {
      final response = await _dio.post(
        '/v1/dashboard/forecasting-feed',
        data: {},
      );

      if (response.statusCode == 200) {
        final List<dynamic> alertsData = response.data['alerts'] ?? [];
        return alertsData.map((item) => ForecastingAlert.fromJson(item)).toList();
      } else {
        throw Exception('Error al obtener feed de predicciones: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }
}

// Inyección de dependencias para Riverpod
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return DashboardRepositoryImpl(dio);
});

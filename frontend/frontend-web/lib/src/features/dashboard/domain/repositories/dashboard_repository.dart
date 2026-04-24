import '../models/dashboard_models.dart';

// Esta es la interfaz que el Backend debe implementar
abstract class DashboardRepository {
  // Obtener estadísticas globales del dashboard
  Future<DashboardStats> getDashboardStats();
  
  // Obtener la lista de activos de alto valor
  Future<List<HoldingItem>> getHighValueHoldings();
  
  // Obtener datos para el gráfico de exposición
  Future<List<ExposureCategory>> getMarketExposureData();
  
  // Obtener los ítems del feed de predicciones
  Future<List<ForecastingAlert>> getForecastingFeed();
}

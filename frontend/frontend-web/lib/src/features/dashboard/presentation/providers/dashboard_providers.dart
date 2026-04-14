import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dashboard_models.dart';
import '../../data/repositories/dashboard_repository_impl.dart';

// Provider para obtener las estadísticas (KPIs) de forma asíncrona
final asyncDashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getDashboardStats();
});

// Provider para obtener los holdings de alto valor de forma asíncrona
final asyncHighValueHoldingsProvider = FutureProvider<List<HoldingItem>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getHighValueHoldings();
});

// Provider para el feed de predicciones
final asyncForecastingFeedProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getForecastingFeed();
});

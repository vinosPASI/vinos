import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dashboard_models.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../data/repositories/vision_repository_impl.dart';
import '../../data/repositories/production_repository_impl.dart';

// ========================================
// Providers del Dashboard (existentes)
// ========================================

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

// ========================================
// Estado y Provider para Vision (Fase 1)
// ========================================

enum AnalysisStatus { initial, uploading, analyzing, success, error }

class AnalyzeLabelState {
  final AnalysisStatus status;
  final AnalyzeWineLabelResponse? result;
  final String? errorMessage;

  AnalyzeLabelState({
    this.status = AnalysisStatus.initial,
    this.result,
    this.errorMessage,
  });

  AnalyzeLabelState copyWith({
    AnalysisStatus? status,
    AnalyzeWineLabelResponse? result,
    String? errorMessage,
  }) {
    return AnalyzeLabelState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

class AnalyzeLabelNotifier extends StateNotifier<AnalyzeLabelState> {
  final Ref _ref;

  AnalyzeLabelNotifier(this._ref) : super(AnalyzeLabelState());

  Future<void> startAnalysis(String fileName, Uint8List bytes) async {
    try {
      state = state.copyWith(status: AnalysisStatus.uploading);

      final repo = _ref.read(visionRepositoryProvider);

      state = state.copyWith(status: AnalysisStatus.analyzing);
      final result = await repo.analyzeLabel(fileName, bytes);

      state = state.copyWith(status: AnalysisStatus.success, result: result);
    } catch (e) {
      state = state.copyWith(
        status: AnalysisStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = AnalyzeLabelState();
  }
}

final analyzeLabelProvider =
    StateNotifierProvider<AnalyzeLabelNotifier, AnalyzeLabelState>((ref) {
  return AnalyzeLabelNotifier(ref);
});

// ========================================
// Provider para Production Alerts (Fase 2)
// ========================================

// Vinos de muestra para simular stockout
final _mockWines = [
  {'id': 'WINE-001', 'name': 'Château Margaux 2015', 'quantity': 5000, 'unit': 'BOTELLA_750ML'},
  {'id': 'WINE-002', 'name': 'Opus One 2018', 'quantity': 3000, 'unit': 'BOTELLA_750ML'},
  {'id': 'WINE-003', 'name': 'Sassicaia 2019', 'quantity': 2000, 'unit': 'BOTELLA_750ML'},
];

class ProductionAlertItem {
  final String wineName;
  final CreateBottlingOrderResponse response;

  ProductionAlertItem({required this.wineName, required this.response});
}

final asyncProductionAlertsProvider = FutureProvider<List<ProductionAlertItem>>((ref) async {
  final repo = ref.watch(productionRepositoryProvider);
  final plannedDate = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  final List<ProductionAlertItem> alerts = [];
  for (final wine in _mockWines) {
    try {
      final result = await repo.simulateStockout(
        wine['id'] as String,
        wine['quantity'] as int,
        wine['unit'] as String,
        plannedDate,
      );
      alerts.add(ProductionAlertItem(
        wineName: wine['name'] as String,
        response: result,
      ));
    } catch (_) {
      // Ignorar fallas individuales, seguir con el siguiente
    }
  }
  return alerts;
});

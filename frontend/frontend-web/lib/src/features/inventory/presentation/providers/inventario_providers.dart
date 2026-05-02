import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/inventario_models.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../data/repositories/ingestion_repository_impl.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../../../shared/utils/authenticated_dio.dart';

// ========================================
// Estado y Provider para Ingesta CSV
// ========================================

enum ImportStatus { initial, uploading, importing, success, error }

class ImportCSVState {
  final ImportStatus status;
  final TriggerDataImportResponse? result;
  final String? errorMessage;

  ImportCSVState({
    this.status = ImportStatus.initial,
    this.result,
    this.errorMessage,
  });

  ImportCSVState copyWith({
    ImportStatus? status,
    TriggerDataImportResponse? result,
    String? errorMessage,
  }) {
    return ImportCSVState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

class ImportCSVNotifier extends StateNotifier<ImportCSVState> {
  final Ref _ref;

  ImportCSVNotifier(this._ref) : super(ImportCSVState());

  Future<void> startImport(String fileName, Uint8List bytes, String entityType) async {
    try {
      state = state.copyWith(status: ImportStatus.uploading);

      final repo = _ref.read(ingestionRepositoryProvider);

      state = state.copyWith(status: ImportStatus.importing);
      final result = await repo.importCSV(fileName, bytes, entityType);

      state = state.copyWith(status: ImportStatus.success, result: result);
    } catch (e) {
      state = state.copyWith(
        status: ImportStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = ImportCSVState();
  }
}

final importCSVProvider =
    StateNotifierProvider<ImportCSVNotifier, ImportCSVState>((ref) {
  return ImportCSVNotifier(ref);
});


final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return InventoryRepositoryImpl(dio);
});

final inventoryListProvider = FutureProvider.autoDispose<List<InventoryItem>>((ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return await repo.getInventoryItems();
});

final inventoryItemDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return await repo.getInventoryItemDetail(id);
});

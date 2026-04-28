import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/storage_service.dart';
import 'package:vinosfront/features/notifications/domain/ingestion_models.dart';
import 'package:vinosfront/features/notifications/data/ingestion_repository_impl.dart';

class IngestionState {
  final bool isLoading;
  final TriggerDataImportResponse? response;
  final String? error;

  IngestionState({this.isLoading = false, this.response, this.error});

  IngestionState copyWith({bool? isLoading, TriggerDataImportResponse? response, String? error, bool clearResponse = false}) {
    return IngestionState(
      isLoading: isLoading ?? this.isLoading,
      response: clearResponse ? null : (response ?? this.response),
      error: error,
    );
  }
}

class IngestionNotifier extends StateNotifier<IngestionState> {
  final Ref _ref;

  IngestionNotifier(this._ref) : super(IngestionState());

  Future<void> triggerCSVImport(String fileName, Uint8List bytes, String entityType) async {
    state = state.copyWith(isLoading: true, error: null, clearResponse: true);
    try {
      final storage = _ref.read(storageServiceProvider);
      final repo = _ref.read(ingestionRepositoryProvider);

      // Paso 1: Subir al Storage
      final objectReference = await storage.uploadFile(fileName, bytes);

      // Paso 2: Disparar el Trigger
      final response = await repo.importCSV(objectReference, entityType);

      state = state.copyWith(isLoading: false, response: response);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final ingestionProvider = StateNotifierProvider<IngestionNotifier, IngestionState>((ref) {
  return IngestionNotifier(ref);
});

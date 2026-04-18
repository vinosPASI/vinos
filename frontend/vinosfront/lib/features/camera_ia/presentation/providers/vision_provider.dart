import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vision_models.dart';
import '../../data/repositories/vision_repository_impl.dart';

class VisionState {
  final bool isLoading;
  final AnalyzeWineLabelResponse? result;
  final String? error;

  VisionState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  VisionState copyWith({
    bool? isLoading,
    AnalyzeWineLabelResponse? result,
    String? error,
    bool clearResult = false,
  }) {
    return VisionState(
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      error: error,
    );
  }
}

class VisionNotifier extends StateNotifier<VisionState> {
  final Ref _ref;

  VisionNotifier(this._ref) : super(VisionState());

  Future<void> analyzeImage(String fileName, Uint8List bytes) async {
    state = state.copyWith(isLoading: true, error: null, clearResult: true);
    try {
      final repo = _ref.read(visionRepositoryProvider);
      final result = await repo.analyzeLabel(fileName, bytes);
      
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = VisionState();
  }
}

final visionProvider = StateNotifierProvider<VisionNotifier, VisionState>((ref) {
  return VisionNotifier(ref);
});

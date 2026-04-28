import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/home_models.dart';
import '../../data/repositories/home_repository_impl.dart';

// Provides the probability of stockout for the default mock wine "WINE-001"
final stockPredictionProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  final response = await repo.simulateBottlingOrder('WINE-001', 5000);
  return response.stockAlert.stockoutProbability;
});

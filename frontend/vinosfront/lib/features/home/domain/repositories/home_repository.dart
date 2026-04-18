import 'package:vinosfront/features/home/domain/entities/home_models.dart';

abstract class HomeRepository {
  Future<CreateBottlingOrderResponse> simulateBottlingOrder(String wineId, int quantity);
}

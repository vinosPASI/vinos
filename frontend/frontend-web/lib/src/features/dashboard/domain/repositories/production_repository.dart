import '../models/dashboard_models.dart';

abstract class ProductionRepository {
  Future<CreateBottlingOrderResponse> simulateStockout(
    String wineId,
    int quantity,
    String unitType,
    int plannedDate,
  );
}

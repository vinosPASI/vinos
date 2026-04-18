import '../models/dashboard_models.dart';

/// Interfaz del repositorio de Producción.
/// Simula una orden de embotellado para obtener alertas predictivas de stock.
abstract class ProductionRepository {
  Future<CreateBottlingOrderResponse> simulateStockout(
    String wineId,
    int quantity,
    String unitType,
    int plannedDate,
  );
}

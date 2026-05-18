import '../entities/inventory_item.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventoryItems();
  Future<Map<String, dynamic>> getInventoryItemDetail(String id);
}

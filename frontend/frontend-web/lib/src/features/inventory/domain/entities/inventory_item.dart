enum StockStatus { red, amber, green }

class InventoryItem {
  final String id;
  final String name;
  final String sku;
  final int realStock;
  final int netStock;
  final String warehouse;

  InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.realStock,
    required this.netStock,
    required this.warehouse,
  });

  StockStatus get status {
    if (netStock <= realStock * 0.2) return StockStatus.red;
    if (netStock <= realStock * 0.5) return StockStatus.amber;
    return StockStatus.green;
  }
}

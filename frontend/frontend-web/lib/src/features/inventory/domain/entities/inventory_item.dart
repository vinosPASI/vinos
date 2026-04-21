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

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      realStock: (json['real_stock'] ?? 0) as int,
      netStock: (json['net_stock'] ?? 0) as int,
      warehouse: json['warehouse'] ?? '',
    );
  }
}

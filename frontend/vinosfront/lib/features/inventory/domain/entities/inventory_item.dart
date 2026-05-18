enum StockStatus { red, amber, green }

class InventoryItem {
  final String id;
  final String name;
  final String sku;
  final String category;
  final int realStock;
  final int netStock;
  final String warehouse;
  final StockStatus status;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.realStock,
    required this.netStock,
    required this.warehouse,
    required this.status,
  });

  static StockStatus calcStatus(int net, int real) {
    if (real == 0) return StockStatus.red;
    final ratio = net / real;
    if (ratio < 0.2) return StockStatus.red;
    if (ratio < 0.5) return StockStatus.amber;
    return StockStatus.green;
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    final real = int.tryParse(map['real_stock']?.toString() ?? '0') ?? 0;
    final net = int.tryParse(map['net_stock']?.toString() ?? '0') ?? 0;
    return InventoryItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      sku: map['sku']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      realStock: real,
      netStock: net,
      warehouse: map['warehouse']?.toString() ?? '',
      status: calcStatus(net, real),
    );
  }
}
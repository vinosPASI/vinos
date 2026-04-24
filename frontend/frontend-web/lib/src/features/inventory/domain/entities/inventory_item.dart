enum StockStatus { red, amber, green }

class InventoryItem {
  final String id;
  final String name;
  final String type;
  final int quantity;
  final String unit;
  final String createdAt;
  final String updatedAt;

  InventoryItem({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.unit,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Desconocido',
      type: json['type']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unit: json['unit']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  /// Estado basado en cantidad: rojo < 100, ámbar < 1000, verde >= 1000
  StockStatus get status {
    if (quantity <= 100) return StockStatus.red;
    if (quantity <= 1000) return StockStatus.amber;
    return StockStatus.green;
  }

  /// Nombre legible del tipo
  String get typeLabel {
    switch (type) {
      case 'lote_vendimia': return 'Lote Vendimia';
      case 'insumo': return 'Insumo';
      case 'producto_terminado': return 'Producto Terminado';
      case 'movimiento': return 'Movimiento';
      default: return type.replaceAll('_', ' ');
    }
  }
}

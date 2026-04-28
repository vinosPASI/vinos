import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventory_item.dart';

final _mockItems = [
  InventoryItem(id: '1', name: 'Uva Malbec', sku: 'UVA-MAL-001', category: 'lote_vendimia', realStock: 5000, netStock: 4200, warehouse: 'Bodega A', status: StockStatus.green),
  InventoryItem(id: '2', name: 'Uva Cabernet', sku: 'UVA-CAB-002', category: 'lote_vendimia', realStock: 3000, netStock: 450, warehouse: 'Bodega A', status: StockStatus.red),
  InventoryItem(id: '3', name: 'Uva Torrontés', sku: 'UVA-TOR-003', category: 'lote_vendimia', realStock: 2000, netStock: 900, warehouse: 'Bodega B', status: StockStatus.amber),
  InventoryItem(id: '4', name: 'Corcho Natural', sku: 'INS-COR-001', category: 'insumo', realStock: 10000, netStock: 8500, warehouse: 'Depósito 1', status: StockStatus.green),
  InventoryItem(id: '5', name: 'Corcho Sintético', sku: 'INS-COR-002', category: 'insumo', realStock: 5000, netStock: 600, warehouse: 'Depósito 1', status: StockStatus.red),
  InventoryItem(id: '6', name: 'Botella 750ml', sku: 'INS-BOT-001', category: 'insumo', realStock: 8000, netStock: 3800, warehouse: 'Depósito 2', status: StockStatus.amber),
  InventoryItem(id: '7', name: 'Etiqueta Malbec 2022', sku: 'INS-ETI-001', category: 'insumo', realStock: 8000, netStock: 7200, warehouse: 'Depósito 2', status: StockStatus.green),
  InventoryItem(id: '8', name: 'Caja Cartón x6', sku: 'INS-CAJ-001', category: 'insumo', realStock: 2000, netStock: 1800, warehouse: 'Depósito 3', status: StockStatus.green),
  InventoryItem(id: '9', name: 'Malbec Reserva 2022', sku: 'PRD-MAL-2022', category: 'producto_terminado', realStock: 1200, netStock: 950, warehouse: 'Cava Principal', status: StockStatus.green),
  InventoryItem(id: '10', name: 'Cabernet Gran Reserva', sku: 'PRD-CAB-2021', category: 'producto_terminado', realStock: 600, netStock: 80, warehouse: 'Cava Principal', status: StockStatus.red),
  InventoryItem(id: '11', name: 'Torrontés Clásico', sku: 'PRD-TOR-2023', category: 'producto_terminado', realStock: 900, netStock: 420, warehouse: 'Cava B', status: StockStatus.amber),
  InventoryItem(id: '12', name: 'Levadura Enológica', sku: 'INS-LEV-001', category: 'insumo', realStock: 500, netStock: 490, warehouse: 'Laboratorio', status: StockStatus.green),
];

final selectedCategoryProvider = StateProvider<String>((ref) => 'todos');

final inventoryListProvider = Provider<List<InventoryItem>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  if (category == 'todos') return _mockItems;
  return _mockItems.where((i) => i.category == category).toList();
});

final inventoryStatsProvider = Provider<Map<String, int>>((ref) {
  final items = ref.watch(inventoryListProvider);
  return {
    'total': items.length,
    'critico': items.where((i) => i.status == StockStatus.red).length,
    'bajo': items.where((i) => i.status == StockStatus.amber).length,
    'normal': items.where((i) => i.status == StockStatus.green).length,
  };
});
import 'package:flutter/material.dart';
import '../../domain/entities/inventory_item.dart';
import 'package:fuzzy/fuzzy.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  final List<InventoryItem> _allInsumos = [
    InventoryItem(id: "1", name: "Malbec Gran Reserva 2021", sku: "W-MAL-01", realStock: 1200, netStock: 300, warehouse: "Central"),
    InventoryItem(id: "2", name: "Botella Bordelesa Vacía", sku: "B-BOR-75", realStock: 5000, netStock: 4800, warehouse: "Insumos"),
    InventoryItem(id: "3", name: "Corcho de Alcornoque Premium", sku: "C-COR-09", realStock: 2000, netStock: 150, warehouse: "Insumos"),
    InventoryItem(id: "4", name: "Chardonnay Barrel Select", sku: "W-CHA-05", realStock: 800, netStock: 750, warehouse: "Norte"),
    InventoryItem(id: "5", name: "Etiqueta Diseño Malbec", sku: "E-MAL-21", realStock: 3000, netStock: 1200, warehouse: "Imprenta"),
  ];

  List<InventoryItem> _filteredInsumos = [];

  @override
  void initState() {
    super.initState();
    _filteredInsumos = _allInsumos;
  }

  void _performFuzzySearch(String query) {
    if (query.isEmpty) {
      setState(() => _filteredInsumos = _allInsumos);
      return;
    }

    final fuse = Fuzzy<InventoryItem>(
      _allInsumos,
      options: FuzzyOptions(
        keys: [
          WeightedKey(name: 'name', getter: (i) => i.name, weight: 1.0),
          WeightedKey(name: 'sku', getter: (i) => i.sku, weight: 0.5),
        ],
        threshold: 0.3,
      ),
    );

    final results = fuse.search(query);
    setState(() {
      _filteredInsumos = results.map((r) => r.item).toList();
    });
  }

  Color _getStatusColor(StockStatus status) {
    switch (status) {
      case StockStatus.red: return Colors.redAccent;
      case StockStatus.amber: return Colors.amber;
      case StockStatus.green: return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        title: const Text("Intelligent Inventory Search (VM-44)"),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _performFuzzySearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search items (Malbec, Corcho, etc...typos allowed)",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: const Icon(Icons.auto_awesome, color: Color(0xFF800020)),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Status", style: TextStyle(color: Colors.white70))),
                      DataColumn(label: Text("Name / SKU", style: TextStyle(color: Colors.white70))),
                      DataColumn(label: Text("Real Stock", style: TextStyle(color: Colors.white70))),
                      DataColumn(label: Text("Net Stock", style: TextStyle(color: Colors.white70))),
                      DataColumn(label: Text("Warehouse", style: TextStyle(color: Colors.white70))),
                    ],
                    rows: _filteredInsumos.map((item) => DataRow(
                      cells: [
                        DataCell(Icon(Icons.circle, color: _getStatusColor(item.status), size: 14)),
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text(item.sku, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                          ],
                        )),
                        DataCell(Text(item.realStock.toString(), style: const TextStyle(color: Colors.white))),
                        DataCell(Text(item.netStock.toString(), 
                          style: TextStyle(color: item.netStock < item.realStock * 0.2 ? Colors.redAccent : Colors.white))),
                        DataCell(Text(item.warehouse, style: const TextStyle(color: Colors.white70))),
                      ],
                    )).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

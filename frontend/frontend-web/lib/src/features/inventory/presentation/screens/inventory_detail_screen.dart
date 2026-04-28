import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/trend_line_chart.dart';
import '../widgets/movement_ledger_list.dart';
import '../providers/inventario_providers.dart';

class InventoryDetailScreen extends ConsumerWidget {
  final String productId;
  final String productName;
  
  const InventoryDetailScreen({
    super.key, 
    required this.productId, 
    required this.productName
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(inventoryItemDetailProvider(productId));

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        title: Text(productName),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.white))),
        data: (data) {
          // Extraer datos del mapa gRPC
          final runwayDays = data['runway_days'] ?? 0;
          final stockoutDate = data['stockout_date'] ?? 'N/A';
          
          // Mapear historial de consumo a FlSpot
          final List<dynamic> consumptionRaw = data['consumption_history'] ?? [];
          final consumptionSpots = consumptionRaw.map((e) => FlSpot(
            (e['x'] as num).toDouble(), 
            (e['y'] as num).toDouble()
          )).toList();

          // Mapear historial de movimientos
          final List<dynamic> movementsRaw = data['movement_history'] ?? [];
          final movementHistory = movementsRaw.map((e) => {
            'date': e['date'],
            'type': e['type'],
            'reference': e['reference'],
            'quantity': e['quantity'],
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ML Forecasting UI
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF800020), Color(0xFF4A0012)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Stock Runway (AI Projection)",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            "$runwayDays Días Restantes",
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Fecha estimada de Stockout: $stockoutDate",
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),

                // Gráfico de Tendencia
                TrendLineChart(spots: consumptionSpots),

                const SizedBox(height: 48),

                // Libro de Movimientos
                MovementLedgerList(movements: movementHistory),
              ],
            ),
          );
        },
      ),
    );
  }
}

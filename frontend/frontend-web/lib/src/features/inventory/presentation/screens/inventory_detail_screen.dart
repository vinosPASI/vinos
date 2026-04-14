import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../widgets/trend_line_chart.dart';
import '../widgets/movement_ledger_list.dart';

class InventoryDetailScreen extends StatelessWidget {
  final String productName;
  
  const InventoryDetailScreen({super.key, required this.productName});

  @override
  Widget build(BuildContext context) {
    // Mock Data para la demo de la VM-50
    final consumptionSpots = [
      const FlSpot(0, 500), const FlSpot(5, 480), const FlSpot(10, 420),
      const FlSpot(15, 300), const FlSpot(20, 250), const FlSpot(25, 120),
      const FlSpot(30, 80),
    ];

    final movementHistory = [
      {'date': '2026-04-05', 'type': 'Remitido', 'reference': 'REM-00452', 'quantity': 45},
      {'date': '2026-04-03', 'type': 'Remitido', 'reference': 'REM-00450', 'quantity': 130},
      {'date': '2026-04-01', 'type': 'Ingreso', 'reference': 'FAC-99120', 'quantity': 1000},
      {'date': '2026-03-28', 'type': 'Remitido', 'reference': 'REM-00448', 'quantity': 60},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        title: Text(productName),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ML Forecasting UI (Runway Section)
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
                      const Text(
                        "12 Días Restantes",
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Fecha estimada de Stockout: 19 Abr 2026",
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
      ),
    );
  }
}

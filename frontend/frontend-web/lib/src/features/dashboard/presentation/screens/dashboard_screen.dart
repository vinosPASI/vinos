import 'package:flutter/material.dart';
import '../widgets/summary_card.dart';
import '../widgets/critical_insumos_list.dart';
import '../widgets/warehouse_distribution_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulando los KPIs calculados por el motor de inferencia (VM-30/31)
    final criticalItems = [
      {'name': 'Botella Bordelesa 750ml', 'net_stock': 120, 'score': 0.85},
      {'name': 'Corcho Natural Extra', 'net_stock': 540, 'score': 0.72},
      {'name': 'Etiqueta Malbec Reserva', 'net_stock': 210, 'score': 0.92},
      {'name': 'Cápsula Plomo Roja', 'net_stock': 450, 'score': 0.65},
    ];

    final warehouseDistribution = {
      'Depósito Central': 45.0,
      'Bodega Norte': 30.0,
      'Depósito Frío': 15.0,
      'Exportación': 10.0,
    };

    return Scaffold(
      backgroundColor: const Color(0xFF131313), // Total Black Surface
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Text(
                "Wine Intelligence Dashboard",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            
            // Sección de KPIs Superiores (SummaryCards)
            const Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                SizedBox(
                  width: 300,
                  child: SummaryCard(
                    title: "Stock Neto Total",
                    value: "24,850",
                    icon: Icons.inventory_2_rounded,
                    trend: "+12.5%",
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: SummaryCard(
                    title: "Alertas de Quiebre",
                    value: "14",
                    icon: Icons.notifications_active_rounded,
                    trend: "-2.1%",
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: SummaryCard(
                    title: "Días para Reabastecimiento",
                    value: "12",
                    icon: Icons.timer_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 56),

            // Sección de Detalle: Gráfico vs Lista Crítica
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna de Gráfico de Almacén
                Expanded(
                  flex: 1,
                  child: WarehouseDistributionChart(data: warehouseDistribution),
                ),
                
                const SizedBox(width: 60),

                // Columna de Lista Crítica
                Expanded(
                  flex: 1,
                  child: CriticalInsumosList(items: criticalItems),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

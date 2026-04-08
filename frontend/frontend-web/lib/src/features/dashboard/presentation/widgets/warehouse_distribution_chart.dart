import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WarehouseDistributionChart extends StatelessWidget {
  final Map<String, double> data;

  const WarehouseDistributionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Text(
            "Distribución de Existencias por Bodega",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 100, // Modern hollow design
              sectionsSpace: 4,
              sections: data.keys.toList().asMap().entries.map((entry) {
                final colors = [
                  const Color(0xFF800020), // Burgundy
                  Colors.amber,
                  Colors.blueGrey,
                  Colors.teal,
                ];
                
                return PieChartSectionData(
                  color: colors[entry.key % colors.length],
                  value: data[entry.value],
                  title: "${data[entry.value]!.toInt()}%",
                  radius: 20,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Simple Legend
        Wrap(
          spacing: 16,
          children: data.keys.toList().asMap().entries.map((entry) {
            final colors = [
              const Color(0xFF800020),
              Colors.amber,
              Colors.blueGrey,
              Colors.teal,
            ];
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[entry.key % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  entry.value,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

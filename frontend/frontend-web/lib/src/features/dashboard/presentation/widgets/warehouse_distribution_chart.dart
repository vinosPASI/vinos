import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class WarehouseDistributionChart extends StatelessWidget {
  final Map<String, double> data;

  const WarehouseDistributionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Colores de respaldo en caso de que el compilador no detecte la paleta global temporalmente
    final fallbackPalette = [
      AppColors.vinoPastel,
      AppColors.vinoOscuro,
      AppColors.doradoPastel,
      const Color(0xFFBC8F8F),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Distribución por Almacén",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textoPrincipal),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: data.entries.map((entry) {
                final index = data.keys.toList().indexOf(entry.key);
                return PieChartSectionData(
                  value: entry.value,
                  title: '${entry.value.toInt()}%',
                  radius: 50,
                  color: fallbackPalette[index % fallbackPalette.length],
                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).toList(),
              sectionsSpace: 4,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Leyenda
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: data.keys.map((key) {
            final index = data.keys.toList().indexOf(key);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: fallbackPalette[index % fallbackPalette.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(key, style: const TextStyle(fontSize: 12, color: AppColors.textoSecundario)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

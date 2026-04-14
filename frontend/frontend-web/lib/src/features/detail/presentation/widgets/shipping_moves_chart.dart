import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class ShippingMovesChart extends StatelessWidget {
  const ShippingMovesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Movimientos de Envío", // Traducido
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textoPrincipal),
                  ),
                  Text(
                    "TENDENCIA DE DISTRIBUCIÓN ÚLTIMOS 6 MESES", // Traducido
                    style: TextStyle(fontSize: 10, color: AppColors.textoSecundario.withOpacity(0.6), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  _chartLegend("VOLUMEN", AppColors.vinoPastel),
                  const SizedBox(width: 16),
                  _chartLegend("VELOCIDAD", AppColors.doradoPastel),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ["ENE", "FEB", "MAR", "ABR", "MAY", "JUN"]; // Traducido
                        return Text(
                          days[value.toInt() % days.length],
                          style: const TextStyle(color: AppColors.textoSecundario, fontSize: 10, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, 40, 20),
                  _makeGroupData(1, 60, 35),
                  _makeGroupData(2, 75, 45),
                  _makeGroupData(3, 50, 30),
                  _makeGroupData(4, 90, 65),
                  _makeGroupData(5, 70, 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 8,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: AppColors.vinoPastel,
          width: 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
        BarChartRodData(
          toY: y2,
          color: AppColors.doradoPastel,
          width: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _chartLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoSecundario)),
      ],
    );
  }
}

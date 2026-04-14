import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class MarketExposureChart extends StatelessWidget {
  const MarketExposureChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 40,
            offset: const Offset(0, 10),
          )
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
                children: const [
                  Text("Exposición de Mercado", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textoPrincipal)),
                  Text("RENDIMIENTO REGIONAL - 6 MESES", style: TextStyle(fontSize: 10, color: AppColors.textoSecundario, fontWeight: FontWeight.bold)),
                ],
              ),
              _buildLegend(),
            ],
          ),
          const SizedBox(height: 48),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.bold);
                        switch (value.toInt()) {
                          case 0: return const Text("ENERO", style: style);
                          case 2: return const Text("MARZO", style: style);
                          case 5: return const Text("JUNIO", style: style);
                        }
                        return const Text("");
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _lineData(AppColors.vinoPastel, [const FlSpot(0, 3), const FlSpot(2, 4), const FlSpot(4, 3.5), const FlSpot(5, 5)]),
                  _lineData(AppColors.doradoPastel, [const FlSpot(0, 1), const FlSpot(2, 2.5), const FlSpot(4, 3), const FlSpot(5, 7)]),
                  _lineData(AppColors.vinoOscuro.withOpacity(0.3), [const FlSpot(0, 2), const FlSpot(2, 2), const FlSpot(4, 4), const FlSpot(5, 4.5)]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _lineData(Color color, List<FlSpot> spots) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.05)),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem("BORDEAUX", AppColors.vinoPastel),
        const SizedBox(width: 16),
        _legendItem("BORGOÑA", AppColors.doradoPastel),
        const SizedBox(width: 16),
        _legendItem("TOSCANA", Colors.black12),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textoSecundario, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

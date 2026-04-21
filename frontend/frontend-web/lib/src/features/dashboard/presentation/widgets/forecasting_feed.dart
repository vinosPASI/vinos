import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/dashboard_providers.dart';

class ForecastingFeed extends ConsumerWidget {
  const ForecastingFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(asyncForecastingFeedProvider);
    final productionAsync = ref.watch(asyncProductionAlertsProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.sand.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Feed de Predicciones", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.wineSecondary)),
              Icon(Icons.auto_awesome, color: AppColors.winePrimary, size: 20),
            ],
          ),
          const SizedBox(height: 32),

          // Feed de predicciones con datos mock del repositorio
          feedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text("Error: $err"),
            data: (items) => Column(
              children: items.map((item) => _feedItem(
                item['tag'], 
                item['name'], 
                item['current'], 
                item['remaining'], 
                item['progress'], 
                _getColorForTag(item['tag'])
              )).toList(),
            ),
          ),
          
          const SizedBox(height: 32),

          // Tarjeta IA Sommelier — conectada a Production API
          productionAsync.when(
            loading: () => _buildAIInsight("Cargando predicciones de stock..."),
            error: (err, stack) => _buildAIInsight("No se pudieron cargar las predicciones."),
            data: (alerts) {
              if (alerts.isEmpty) {
                return _buildAIInsight("Sin datos suficientes para predicción - pendiente implementación");
              }
              // Encontrar la alerta más crítica
              final mostCritical = alerts.reduce((a, b) =>
                a.response.stockAlert.stockoutProbability >= b.response.stockAlert.stockoutProbability ? a : b);
              return _buildAIInsight(
                mostCritical.response.stockAlert.diagnosticMessage.isNotEmpty
                    ? '"${mostCritical.response.stockAlert.diagnosticMessage}"'
                    : '"Probabilidad de stockout para ${mostCritical.wineName}: ${(mostCritical.response.stockAlert.stockoutProbability * 100).toStringAsFixed(0)}%"',
              );
            },
          ),

          const SizedBox(height: 24),
          _buildDetailButton(),
        ],
      ),
    );
  }

  Color _getColorForTag(String tag) {
    if (tag.contains("CRÍTICO")) return Colors.redAccent;
    if (tag.contains("PROBABLE")) return Colors.orangeAccent;
    return AppColors.winePrimary;
  }

  Widget _feedItem(String tag, String name, String current, String remaining, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tag, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(color: AppColors.wineSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Actual: $current", style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text(remaining, style: const TextStyle(color: AppColors.wineSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.black12,
            color: color,
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsight(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.wineSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.psychology_outlined, color: AppColors.sand, size: 18),
              SizedBox(width: 8),
              Text("Sugerencia IA Sommelier", style: TextStyle(color: AppColors.sand, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailButton() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 45),
        side: const BorderSide(color: AppColors.winePrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text("VER PREDICCIÓN DETALLADA", style: TextStyle(color: AppColors.winePrimary, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/dashboard_providers.dart';

class ForecastingFeed extends ConsumerWidget {
  const ForecastingFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(asyncForecastingFeedProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.amarilloVainilla.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.doradoPastel.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Feed de Predicciones", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textoPrincipal)),
              Icon(Icons.auto_awesome, color: AppColors.vinoPastel, size: 20),
            ],
          ),
          const SizedBox(height: 32),
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
          _buildAIInsight(),
          const SizedBox(height: 24),
          _buildDetailButton(),
        ],
      ),
    );
  }

  Color _getColorForTag(String tag) {
    if (tag.contains("CRÍTICO")) return Colors.redAccent;
    if (tag.contains("PROBABLE")) return Colors.orangeAccent;
    return AppColors.vinoPastel;
  }

  Widget _feedItem(String tag, String name, String current, String remaining, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tag, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Actual: $current", style: const TextStyle(color: AppColors.textoSecundario, fontSize: 11)),
              Text(remaining, style: const TextStyle(color: AppColors.textoPrincipal, fontSize: 11, fontWeight: FontWeight.bold)),
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

  Widget _buildAIInsight() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.vinoOscuro,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.psychology_outlined, color: AppColors.doradoPastel, size: 18),
              SizedBox(width: 8),
              Text("Sugerencia IA Sommelier", style: TextStyle(color: AppColors.doradoPastel, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "\"La demanda del mercado para el Bordeaux 2015 está aumentando debido a los bajos rendimientos de la temporada actual.\"",
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5, fontStyle: FontStyle.italic),
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
        side: const BorderSide(color: AppColors.vinoPastel),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text("VER PREDICCIÓN DETALLADA", style: TextStyle(color: AppColors.vinoPastel, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

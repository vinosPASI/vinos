import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

import '../../domain/models/dashboard_models.dart';

class CriticalInsumosList extends StatelessWidget {
  final List<ForecastingAlert> items;

  const CriticalInsumosList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Insumos Críticos",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.wineSecondary),
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.sand, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 40,
                    decoration: BoxDecoration(
                      color: item.severity == 'HIGH' ? Colors.redAccent : AppColors.winePrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.message, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.wineSecondary)),
                        Text("Creado: ${item.createdAt}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Icon(Icons.warning_amber_rounded, color: AppColors.winePrimary, size: 20),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

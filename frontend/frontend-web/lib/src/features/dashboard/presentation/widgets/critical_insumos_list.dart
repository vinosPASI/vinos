import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class CriticalInsumosList extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const CriticalInsumosList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Insumos Críticos",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textoPrincipal),
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
                color: AppColors.cremaClaro,
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.doradoPastel, width: 0.5), // CORREGIDO AQUÍ
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 40,
                    decoration: BoxDecoration(
                      color: item['score'] > 0.8 ? Colors.redAccent : AppColors.vinoPastel,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoPrincipal)),
                        Text("Stock: ${item['net_stock']} unidades", style: const TextStyle(fontSize: 12, color: AppColors.textoSecundario)),
                      ],
                    ),
                  ),
                  const Icon(Icons.warning_amber_rounded, color: AppColors.vinoPastel, size: 20),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

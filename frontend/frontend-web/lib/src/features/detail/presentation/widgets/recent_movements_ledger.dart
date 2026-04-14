import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../data/repositories/detail_repository.dart';

class RecentMovementsLedger extends StatelessWidget {
  final List<StockMovement> movements;

  const RecentMovementsLedger({super.key, required this.movements});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Movimientos Recientes",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textoPrincipal),
        ),
        const SizedBox(height: 24),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movements.length,
          separatorBuilder: (context, index) => const Divider(height: 32, color: Colors.black12, thickness: 0.5),
          itemBuilder: (context, index) {
            final move = movements[index];
            
            // Mapeo manual de iconos basado en el título o lógica (temporal)
            IconData moveIcon = Icons.local_shipping_outlined;
            if (move.title.contains("Restock") || move.title.contains("Reposición")) moveIcon = Icons.home_work_outlined;
            if (move.title.contains("Online") || move.title.contains("Línea")) moveIcon = Icons.shopping_bag_outlined;
            if (move.title.contains("Export")) moveIcon = Icons.flight_takeoff_rounded;
            if (move.title.contains("Audit") || move.title.contains("Auditoría")) moveIcon = Icons.fact_check_outlined;

            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.cremaClaro, borderRadius: BorderRadius.circular(12)),
                  child: Icon(moveIcon, color: AppColors.vinoOscuro, size: 20),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(move.title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textoPrincipal)),
                      Text(move.sub, style: const TextStyle(fontSize: 10, color: AppColors.textoSecundario, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      move.val,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: move.isRed ? const Color(0xFFD32F2F) : const Color(0xFF388E3C),
                      ),
                    ),
                    Text(move.time, style: const TextStyle(fontSize: 9, color: AppColors.textoSecundario)),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 48),
        Row(
          children: [
            _buildButton("AJUSTAR ASIGNACIÓN", isPrimary: true),
            const SizedBox(width: 16),
            _buildButton("GENERAR REPORTE", isPrimary: false),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(String label, {required bool isPrimary}) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.vinoPastel : Colors.transparent,
        foregroundColor: isPrimary ? Colors.white : AppColors.textoPrincipal,
        elevation: isPrimary ? 2 : 0,
        side: isPrimary ? null : const BorderSide(color: Colors.black12),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
    );
  }
}

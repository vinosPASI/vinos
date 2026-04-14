import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/navigation_providers.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/shared_sidebar.dart';
import '../../../../shared/widgets/shared_header.dart';
import '../widgets/wine_projection_card.dart';
import '../widgets/shipping_moves_chart.dart';
import '../widgets/recent_movements_ledger.dart';
import '../../data/repositories/detail_repository.dart';

class PredictiveDetailScreen extends ConsumerWidget {
  const PredictiveDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wineDetailAsync = ref.watch(asyncWineDetailProvider('1'));

    return Scaffold(
      backgroundColor: AppColors.cremaClaro,
      body: Row(
        children: [
          const SharedSidebar(activePage: 'detail'),
          Expanded(
            child: wineDetailAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.vinoPastel)),
              error: (err, stack) => Center(child: Text("Error: $err")),
              data: (detail) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 0),
                child: Column(
                  children: [
                    const SharedHeader(title: "Detalle de Cosecha"),
                    const SizedBox(height: 48),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: WineProjectionCard(
                            projection: "Faltan 14 Días",
                            realStock: detail.realStock,
                            netStock: detail.netStock,
                          ),
                        ),
                        const SizedBox(width: 48),
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoSection(detail),
                              const SizedBox(height: 48),
                              const ShippingMovesChart(),
                              const SizedBox(height: 48),
                              RecentMovementsLedger(movements: detail.movements),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(dynamic detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.vinoOscuro, 
                borderRadius: BorderRadius.circular(4)
              ),
              child: const Text(
                "GRAN RESERVA", 
                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "COSECHA 2018", 
              style: TextStyle(color: AppColors.textoSecundario, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          detail.name,
          style: const TextStyle(
            fontSize: 64, 
            fontWeight: FontWeight.bold, 
            color: AppColors.textoPrincipal, 
            height: 1.0,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          detail.description,
          style: const TextStyle(fontSize: 15, color: AppColors.textoSecundario, height: 1.7),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/shared_sidebar.dart';
import '../../../../shared/widgets/shared_header.dart';
import '../widgets/summary_card.dart';
import '../widgets/market_exposure_chart.dart';
import '../widgets/forecasting_feed.dart';
import '../widgets/high_value_holdings_table.dart';
import '../widgets/add_harvest_modal.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(asyncDashboardStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          const SharedSidebar(activePage: 'dashboard'),
          Expanded(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: SharedHeader(title: "Inteligencia de Cava"),
                ),
                Expanded(
                  child: statsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.winePrimary)),
                    error: (err, stack) => Center(child: Text("Error al cargar datos: $err")),
                    data: (stats) => SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildKPIRow(stats),
                                const SizedBox(height: 32),
                                const MarketExposureChart(),
                                const SizedBox(height: 32),
                                const HighValueHoldingsTable(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          const Expanded(
                            flex: 3,
                            child: ForecastingFeed(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIRow(dynamic stats) {
    return Row(
      children: [
        Expanded(
          child: SummaryCard(
            title: "STOCK NETO TOTAL",
            value: "${stats.totalBottles} BTL",
            icon: Icons.inventory_2_rounded,
            trend: "+0%", // Ya no viene en el backend temporalmente
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: SummaryCard(
            title: "ALERTAS URGENTES",
            value: stats.pendingAlerts.toString(),
            icon: Icons.warning_rounded,
            trend: "N/A", // Ya no viene en el backend temporalmente
          ),
        ),
      ],
    );
  }
}

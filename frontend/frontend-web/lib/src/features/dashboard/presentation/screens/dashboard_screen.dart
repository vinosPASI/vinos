import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../widgets/summary_card.dart';
import '../widgets/market_exposure_chart.dart';
import '../widgets/forecasting_feed.dart';
import '../widgets/high_value_holdings_table.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos los proveedores asíncronos
    final statsAsync = ref.watch(asyncDashboardStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.cremaClaro,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: statsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.vinoPastel)),
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

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: AppColors.vinoOscuro,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Vinoteca Intelligence", 
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const Text("SOMMELIER ELITE PREMIUM", 
            style: TextStyle(color: AppColors.doradoPastel, fontSize: 10, letterSpacing: 1.2)),
          const SizedBox(height: 48),
          _sidebarItem(Icons.grid_view_rounded, "PANEL DE CONTROL", active: true),
          _sidebarItem(Icons.inventory_2_outlined, "INVENTARIO"),
          _sidebarItem(Icons.analytics_outlined, "ANALÍTICA"),
          _sidebarItem(Icons.trending_up_rounded, "PREDICCIONES"),
          _sidebarItem(Icons.settings_outlined, "AJUSTES"),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vinoPastel,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("AÑADIR COSECHA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(backgroundColor: AppColors.doradoPastel, child: Text("A", style: TextStyle(color: AppColors.vinoOscuro, fontWeight: FontWeight.bold))),
            title: const Text("Angel", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: const Text("ADMINISTRADOR", style: TextStyle(color: Colors.white38, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: active ? AppColors.doradoPastel : Colors.white38, size: 20),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(
            color: active ? Colors.white : Colors.white38, 
            fontSize: 13, 
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 1.0
          )),
          if (active) ...[
            const Spacer(),
            Container(width: 2, height: 20, color: AppColors.doradoPastel),
          ]
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Inteligencia de Cava", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textoPrincipal)),
          Icon(Icons.search, color: AppColors.textoSecundario),
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
            value: "${stats.totalNetStock.toInt()} BTL",
            icon: Icons.inventory_2_rounded,
            trend: stats.stockTrend,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: SummaryCard(
            title: "ALERTAS URGENTES",
            value: stats.urgentAlerts.toString(),
            icon: Icons.warning_rounded,
            trend: stats.alertsTrend,
          ),
        ),
      ],
    );
  }
}

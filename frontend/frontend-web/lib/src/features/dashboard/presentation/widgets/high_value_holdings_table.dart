import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/navigation_providers.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/dashboard_providers.dart';

class HighValueHoldingsTable extends ConsumerWidget {
  const HighValueHoldingsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingsAsync = ref.watch(asyncHighValueHoldingsProvider);

    return Container(
      padding: const EdgeInsets.all(32),
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
              const Text("Activos de Alto Valor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textoPrincipal)),
              Text("ÚLTIMA REVALORIZACIÓN: HACE 2H", style: TextStyle(fontSize: 10, color: AppColors.textoSecundario, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          holdingsAsync.when(
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            )),
            error: (err, stack) => Text("Error: $err"),
            data: (holdings) => Table(
              columnWidths: const {
                0: FlexColumnWidth(4),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                _buildHeaderRow(),
                ...holdings.map((item) => _buildDataRow(ref, item.name, item.region, "\$${item.value.toInt()}", item.trend)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return const TableRow(
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("NOMBRE DE COSECHA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("REGIÓN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("VALOR (USD)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("TENDENCIA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26))),
      ],
    );
  }

  TableRow _buildDataRow(WidgetRef ref, String name, String region, String value, String trend) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: InkWell(
            onTap: () => ref.read(navigationProvider.notifier).state = 'detail',
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16), 
              child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.vinoPastel, decoration: TextDecoration.underline))
            ),
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text(region, style: const TextStyle(fontSize: 13, color: AppColors.textoSecundario))),
        Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textoPrincipal))),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16), 
          child: Text(trend, style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.bold, 
            color: trend.contains('+') ? Colors.green : Colors.redAccent
          ))
        ),
      ],
    );
  }
}

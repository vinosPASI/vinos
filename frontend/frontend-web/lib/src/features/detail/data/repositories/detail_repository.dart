import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modelo simplificado para los movimientos
class StockMovement {
  final String title;
  final String sub;
  final String val;
  final String time;
  final bool isRed;
  final dynamic icon;

  StockMovement({required this.title, required this.sub, required this.val, required this.time, required this.isRed, this.icon});
}

// Modelo para el detalle del vino
class WineDetail {
  final String name;
  final String vintage;
  final String description;
  final String stockoutProjection;
  final int realStock;
  final int netStock;
  final List<StockMovement> movements;

  WineDetail({
    required this.name,
    required this.vintage,
    required this.description,
    required this.stockoutProjection,
    required this.realStock,
    required this.netStock,
    required this.movements,
  });
}

// REPOSITORIO DE DETALLE
abstract class DetailRepository {
  Future<WineDetail> getWineDetail(String id);
}

class DetailRepositoryImpl implements DetailRepository {
  @override
  Future<WineDetail> getWineDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // TODO: SUSTITUIR POR LLAMADA A API (GET /inventory/{id})
    return WineDetail(
      name: "Merlot Grand Reserve",
      vintage: "VINTAGE 2018",
      description: "An exceptional vintage characterized by its balanced structure and deep aromatic profile. This Merlot from the Grand Reserve collection represents the pinnacle of our vineyard's craft, aged to perfection for those who appreciate true lineage.",
      stockoutProjection: "14 Days Remaining",
      realStock: 428,
      netStock: 404,
      movements: [
        StockMovement(title: "To Boutique SOHO", sub: "ALLOCATED DISPATCH", val: "-24 cases", time: "2 HOURS AGO", isRed: true),
        StockMovement(title: "Restock: Vineyard Warehouse", sub: "INBOUND LOGISTICS", val: "+120 cases", time: "YESTERDAY", isRed: false),
        StockMovement(title: "Online Direct Order #842", sub: "DIRECT TO CONSUMER", val: "-2 cases", time: "3 DAYS AGO", isRed: true),
        StockMovement(title: "Export: London Hub", sub: "INTERNATIONAL TRADE", val: "-48 cases", time: "MAY 12, 2024", isRed: true),
        StockMovement(title: "Inventory Audit Adjustment", sub: "INTERNAL RECONCILIATION", val: "-1 unit", time: "MAY 08, 2024", isRed: true),
      ],
    );
  }
}

// PROVIDERS
final detailRepositoryProvider = Provider<DetailRepository>((ref) => DetailRepositoryImpl());

final asyncWineDetailProvider = FutureProvider.family<WineDetail, String>((ref, id) async {
  final repo = ref.watch(detailRepositoryProvider);
  return repo.getWineDetail(id);
});

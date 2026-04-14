import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dashboard_models.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../dashboard_mock_data.dart'; 

/// IMPLEMENTACIÓN DEL REPOSITORIO
/// 
/// INSTRUCCIONES PARA EL EQUIPO DE BACKEND:
/// 1. Para conectar con la API real, sustituyan los datos del Mock por llamadas a 'http' o 'dio'.
/// 2. Importen 'http' (package:http/http.dart as http).
/// 3. Usen 'DashboardStats.fromJson(jsonDecode(response.body))' para mapear los datos.
class DashboardRepositoryImpl implements DashboardRepository {
  
  @override
  Future<DashboardStats> getDashboardStats() async {
    // TODO: SUSTITUIR POR LLAMADA REAL A LA API
    // Ejemplo: 
    // final response = await http.get(Uri.parse('https://api.vinoteca.ml/stats'));
    // return DashboardStats.fromJson(jsonDecode(response.body));
    
    await Future.delayed(const Duration(milliseconds: 500)); 
    
    double parseMockValue(String? val) {
      if (val == null) return 0.0;
      return double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }

    return DashboardStats(
      totalNetStock: parseMockValue(dashboardKPIsMock['total_net_stock']),
      urgentAlerts: int.tryParse(dashboardKPIsMock['out_of_stock_alerts'] ?? '0') ?? 0,
      stockTrend: dashboardKPIsMock['stock_trend'] ?? "",
      alertsTrend: dashboardKPIsMock['alerts_trend'] ?? "SIN ALERTAS",
    );
  }

  @override
  Future<List<HoldingItem>> getHighValueHoldings() async {
    // TODO: SUSTITUIR POR LLAMADA REAL A LA API
    // Ejemplo:
    // final response = await http.get(Uri.parse('https://api.vinoteca.ml/holdings'));
    // final List<dynamic> data = jsonDecode(response.body);
    // return data.map((item) => HoldingItem.fromJson(item)).toList();

    await Future.delayed(const Duration(milliseconds: 600));
    return [
      HoldingItem(name: "Domaine de la Romanée-Conti 2010", region: "Borgoña", value: 18240.0, trend: "+12.4%"),
      HoldingItem(name: "Château Mouton Rothschild 1982", region: "Pauillac", value: 1850.0, trend: "+4.2%"),
      HoldingItem(name: "Screaming Eagle Cabernet 2015", region: "Napa Valley", value: 4200.0, trend: "-1.5%"),
    ];
  }

  @override
  Future<Map<String, List<double>>> getMarketExposureData() async {
    // TODO: SUSTITUIR POR DATOS DINÁMICOS DEL GRÁFICO
    return {
      "BORDEAUX": [3, 4, 3.5, 5],
      "BORGOÑA": [1, 2.5, 3, 7],
      "TOSCANA": [2, 2, 4, 4.5],
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getForecastingFeed() async {
    // TODO: CONECTAR CON EL FEED DE PREDICCIONES
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {"tag": "STOCK CRÍTICO", "name": "Château Margaux 2015", "current": "24 BTL", "remaining": "14 DÍAS", "progress": 0.8},
      {"tag": "STOCK PROBABLE", "name": "Opus One 2018", "current": "42 BTL", "remaining": "22 DÍAS", "progress": 0.5},
      {"tag": "ALERTA DE PEDIDO", "name": "Sassicaia 2019", "current": "18 BTL", "remaining": "31 DÍAS", "progress": 0.3},
    ];
  }
}

// Inyección de dependencias para Riverpod
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl();
});

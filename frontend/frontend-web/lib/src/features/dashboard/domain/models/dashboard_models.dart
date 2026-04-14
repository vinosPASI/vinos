import 'package:flutter_riverpod/flutter_riverpod.dart';

// Este modelo define cómo debe ser la respuesta del Backend para los KPIs
class DashboardStats {
  final double totalNetStock;
  final int urgentAlerts;
  final String stockTrend;
  final String alertsTrend;

  DashboardStats({
    required this.totalNetStock,
    required this.urgentAlerts,
    required this.stockTrend,
    required this.alertsTrend,
  });

  // El Backend usará esto para mapear su JSON
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalNetStock: (json['total_net_stock'] as num).toDouble(),
      urgentAlerts: json['urgent_alerts'] as int,
      stockTrend: json['stock_trend'] as String,
      alertsTrend: json['alerts_trend'] as String,
    );
  }
}

// Modelo para los vinos de alto valor
class HoldingItem {
  final String name;
  final String region;
  final double value;
  final String trend;

  HoldingItem({required this.name, required this.region, required this.value, required this.trend});

  factory HoldingItem.fromJson(Map<String, dynamic> json) {
    return HoldingItem(
      name: json['name'] as String,
      region: json['region'] as String,
      value: (json['value'] as num).toDouble(),
      trend: json['trend'] as String,
    );
  }
}

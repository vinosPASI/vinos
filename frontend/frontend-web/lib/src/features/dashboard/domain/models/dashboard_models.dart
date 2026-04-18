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

// ========================================
// Modelos para VisionService (Fase 1)
// ========================================

class StructuredWineData {
  final String brand;
  final String cepaVariedad;
  final int vintageYear;
  final String volumeContent;

  StructuredWineData({
    required this.brand,
    required this.cepaVariedad,
    required this.vintageYear,
    required this.volumeContent,
  });

  factory StructuredWineData.fromJson(Map<String, dynamic> json) {
    return StructuredWineData(
      brand: json['brand'] ?? '',
      cepaVariedad: json['cepa_variedad'] ?? '',
      vintageYear: json['vintage_year'] ?? 0,
      volumeContent: json['volume_content'] ?? '',
    );
  }
}

class WineClassification {
  final String label;
  final double confidenceLevel;

  WineClassification({required this.label, required this.confidenceLevel});

  factory WineClassification.fromJson(Map<String, dynamic> json) {
    return WineClassification(
      label: json['label'] ?? '',
      confidenceLevel: (json['confidence_level'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AnalyzeWineLabelResponse {
  final String rawOcrText;
  final WineClassification classification;
  final StructuredWineData wineData;

  AnalyzeWineLabelResponse({
    required this.rawOcrText,
    required this.classification,
    required this.wineData,
  });

  factory AnalyzeWineLabelResponse.fromJson(Map<String, dynamic> json) {
    return AnalyzeWineLabelResponse(
      rawOcrText: json['raw_ocr_text'] ?? '',
      classification: WineClassification.fromJson(json['classification'] ?? {}),
      wineData: StructuredWineData.fromJson(json['wine_data'] ?? {}),
    );
  }
}

// ========================================
// Modelos para ProductionService (Fase 2)
// ========================================

class PredictiveStockAlert {
  final double stockoutProbability;
  final String diagnosticMessage;

  PredictiveStockAlert({
    required this.stockoutProbability,
    required this.diagnosticMessage,
  });

  factory PredictiveStockAlert.fromJson(Map<String, dynamic> json) {
    return PredictiveStockAlert(
      stockoutProbability: (json['stockout_probability'] as num?)?.toDouble() ?? 0.0,
      diagnosticMessage: json['diagnostic_message'] ?? '',
    );
  }
}

class CreateBottlingOrderResponse {
  final String status;
  final List<dynamic> materialBreakdown;
  final PredictiveStockAlert stockAlert;

  CreateBottlingOrderResponse({
    required this.status,
    required this.materialBreakdown,
    required this.stockAlert,
  });

  factory CreateBottlingOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateBottlingOrderResponse(
      status: json['status'] ?? '',
      materialBreakdown: json['material_breakdown'] ?? [],
      stockAlert: PredictiveStockAlert.fromJson(json['stock_alert'] ?? {}),
    );
  }
}

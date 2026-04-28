import 'package:flutter_riverpod/flutter_riverpod.dart';

// Este modelo define cómo debe ser la respuesta del Backend para los KPIs
class DashboardStats {
  final int totalBottles;
  final double totalValue;
  final int categoriesCount;
  final int pendingAlerts;

  DashboardStats({
    required this.totalBottles,
    required this.totalValue,
    required this.categoriesCount,
    required this.pendingAlerts,
  });

  // El Backend usará esto para mapear su JSON transcoded desde gRPC
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalBottles: json['total_bottles'] ?? 0,
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
      categoriesCount: json['categories_count'] ?? 0,
      pendingAlerts: json['pending_alerts'] ?? 0,
    );
  }
}

// Modelo para los vinos de alto valor
class HoldingItem {
  final String name;
  final String category;
  final double value;
  final double percentageOfPortfolio;

  HoldingItem({required this.name, required this.category, required this.value, required this.percentageOfPortfolio});

  factory HoldingItem.fromJson(Map<String, dynamic> json) {
    return HoldingItem(
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      percentageOfPortfolio: (json['percentage_of_portfolio'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Modelo para Exposición de Mercado
class ExposureCategory {
  final String categoryName;
  final double value;
  final double percentage;

  ExposureCategory({required this.categoryName, required this.value, required this.percentage});

  factory ExposureCategory.fromJson(Map<String, dynamic> json) {
    return ExposureCategory(
      categoryName: json['category_name'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Modelo para Predicciones y Alertas
class ForecastingAlert {
  final String id;
  final String message;
  final String severity;
  final String createdAt;
  final String relatedItemId;

  ForecastingAlert({
    required this.id,
    required this.message,
    required this.severity,
    required this.createdAt,
    required this.relatedItemId,
  });

  factory ForecastingAlert.fromJson(Map<String, dynamic> json) {
    return ForecastingAlert(
      id: json['id'] as String? ?? '',
      message: json['message'] as String? ?? '',
      severity: json['severity'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      relatedItemId: json['related_item_id'] as String? ?? '',
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

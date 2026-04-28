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
      brand: json['brand'] ?? 'Desconocida',
      cepaVariedad: json['cepa_variedad'] ?? 'Desconocida',
      vintageYear: json['vintage_year'] ?? 0,
      volumeContent: json['volume_content'] ?? '750ml',
    );
  }
}

class WineClassification {
  final String label;
  final double confidenceLevel;

  WineClassification({
    required this.label,
    required this.confidenceLevel,
  });

  factory WineClassification.fromJson(Map<String, dynamic> json) {
    return WineClassification(
      label: json['label'] ?? '',
      confidenceLevel: (json['confidence_level'] ?? 0.0).toDouble(),
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

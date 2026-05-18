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
      cepaVariedad: json['cepa_variedad'] ?? json['cepaVariedad'] ?? '',
      vintageYear: (json['vintage_year'] ?? json['vintageYear'] ?? 0) as int,
      volumeContent: json['volume_content'] ?? json['volumeContent'] ?? '',
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
  final String sommelierNote;

  AnalyzeWineLabelResponse({
    required this.rawOcrText,
    required this.classification,
    required this.wineData,
    this.sommelierNote = '',
  });

  factory AnalyzeWineLabelResponse.fromJson(Map<String, dynamic> json) {
    return AnalyzeWineLabelResponse(
      rawOcrText: json['raw_ocr_text'] ?? json['rawOcrText'] ?? '',
      classification: WineClassification.fromJson(json['classification'] ?? {}),
      wineData: StructuredWineData.fromJson(json['wine_data'] ?? json['wineData'] ?? {}),
      sommelierNote: json['sommelier_note'] ?? json['sommelierNote'] ?? '',
    );
  }
}

class StockAlert {
  final double stockoutProbability;
  final String diagnosticMessage;

  StockAlert({
    required this.stockoutProbability,
    required this.diagnosticMessage,
  });

  factory StockAlert.fromJson(Map<String, dynamic> json) {
    return StockAlert(
      stockoutProbability: (json['stockout_probability'] ?? 0.0).toDouble(),
      diagnosticMessage: json['diagnostic_message'] ?? '',
    );
  }
}

class CreateBottlingOrderResponse {
  final String status;
  final StockAlert stockAlert;

  CreateBottlingOrderResponse({
    required this.status,
    required this.stockAlert,
  });

  factory CreateBottlingOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateBottlingOrderResponse(
      status: json['status'] ?? '',
      stockAlert: StockAlert.fromJson(json['stock_alert'] ?? {}),
    );
  }
}

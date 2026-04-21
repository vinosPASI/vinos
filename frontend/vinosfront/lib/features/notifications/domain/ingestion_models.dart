class TriggerDataImportResponse {
  final bool success;
  final int insertedRows;
  final List<String> errors;

  TriggerDataImportResponse({
    required this.success,
    required this.insertedRows,
    required this.errors,
  });

  factory TriggerDataImportResponse.fromJson(Map<String, dynamic> json) {
    return TriggerDataImportResponse(
      success: json['success'] ?? false,
      insertedRows: json['inserted_rows'] ?? 0,
      errors: List<String>.from(json['errors'] ?? []),
    );
  }
}

/// Modelos para el servicio de ingesta de datos (IngestionService).

class ImportError {
  final String field;
  final String message;
  final int? row;

  ImportError({required this.field, required this.message, this.row});

  factory ImportError.fromJson(Map<String, dynamic> json) {
    return ImportError(
      field: json['field'] ?? '',
      message: json['message'] ?? '',
      row: json['row'],
    );
  }
}

class TriggerDataImportResponse {
  final bool success;
  final int insertedRows;
  final List<ImportError> errors;

  TriggerDataImportResponse({
    required this.success,
    required this.insertedRows,
    required this.errors,
  });

  factory TriggerDataImportResponse.fromJson(Map<String, dynamic> json) {
    final errorsList = (json['errors'] as List<dynamic>?)
        ?.map((e) => ImportError.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    return TriggerDataImportResponse(
      success: json['success'] ?? false,
      insertedRows: json['inserted_rows'] ?? 0,
      errors: errorsList,
    );
  }
}

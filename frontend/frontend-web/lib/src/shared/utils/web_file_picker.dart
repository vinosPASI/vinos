import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

/// Resultado de selección de archivo en Web.
class WebFilePickerResult {
  final String name;
  final Uint8List bytes;

  WebFilePickerResult({required this.name, required this.bytes});
}

/// File picker nativo para Flutter Web usando dart:html.
/// Evita el bug de LateInitializationError de file_picker package.
class WebFilePicker {
  /// Abre el diálogo nativo del navegador para seleccionar un archivo.
  /// [accept] es el MIME type filter (ej. 'image/*', '.csv', '*/*').
  static Future<WebFilePickerResult?> pickFile({String accept = '*/*'}) async {
    final completer = Completer<WebFilePickerResult?>();

    final input = html.FileUploadInputElement()..accept = accept;
    input.click();

    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }

      final file = files.first;
      final reader = html.FileReader();

      reader.onLoadEnd.listen((event) {
        final result = reader.result as Uint8List;
        completer.complete(WebFilePickerResult(
          name: file.name,
          bytes: result,
        ));
      });

      reader.onError.listen((event) {
        completer.complete(null);
      });

      reader.readAsArrayBuffer(file);
    });

    // Si el usuario cancela el diálogo
    // En Web, no hay evento de cancelación confiable, pero el onChange no se dispara.
    // Usamos un timeout como fallback.
    html.window.addEventListener('focus', (event) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });
    });

    return completer.future;
  }
}

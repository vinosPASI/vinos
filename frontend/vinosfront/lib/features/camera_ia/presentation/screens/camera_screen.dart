import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/vision_repository_impl.dart';

/// Tipos de mensaje en el chat
enum _ChatBubbleType { bot, image, loading, error }

/// Modelo de un mensaje del chat
class _ChatMessage {
  final _ChatBubbleType type;
  final String? text;
  final File? imageFile;

  _ChatMessage({required this.type, this.text, this.imageFile});
}

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isAnalyzing = false;

  static const Color vinoOscuro = Color(0xFF6E3B47);
  static const Color vinoPastel = Color(0xFF8C4A5A);
  static const Color amarilloVainilla = Color(0xFFF3E5AB);
  static const Color doradoPastel = Color(0xFFE6D3A3);
  static const Color cremaClaro = Color(0xFFF8F5F0);

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      type: _ChatBubbleType.bot,
      text: "Hola 👋 Toma una foto de la etiqueta o botella de vino, o adjunta una imagen desde la galería para comenzar el análisis.",
    ));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      await _processImage(pickedFile);
    }
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _processImage(pickedFile);
    }
  }

  Future<void> _processImage(XFile pickedFile) async {
    final file = File(pickedFile.path);
    final bytes = await pickedFile.readAsBytes();

    setState(() {
      _messages.add(_ChatMessage(type: _ChatBubbleType.image, imageFile: file));
      _messages.add(_ChatMessage(type: _ChatBubbleType.loading));
      _isAnalyzing = true;
    });
    _scrollToBottom();

    try {
      final repo = ref.read(visionRepositoryProvider);
      final result = await repo.analyzeLabel(pickedFile.name, bytes);

      setState(() {
        // Quitar el indicador de carga
        _messages.removeWhere((m) => m.type == _ChatBubbleType.loading);
        _messages.add(_ChatMessage(
          type: _ChatBubbleType.bot,
          text: "💡 ¡Análisis completado!\n\n"
              "🏷️ Marca: ${result.wineData.brand}\n"
              "🍇 Variedad: ${result.wineData.cepaVariedad}\n"
              "📅 Año: ${result.wineData.vintageYear > 0 ? result.wineData.vintageYear : 'N/A'}\n"
              "📏 Volumen: ${result.wineData.volumeContent}",
        ));
        
        if (result.sommelierNote.isNotEmpty) {
          _messages.add(_ChatMessage(
            type: _ChatBubbleType.bot,
            text: "🍷 Recomendación del Sommelier:\n\n${result.sommelierNote}",
          ));
        }

        _isAnalyzing = false;
      });
    } catch (e) {
      String userFriendlyError = e.toString();
      
      // Intentar extraer el mensaje de error del backend si es una respuesta controlada
      if (e is dynamic && e.runtimeType.toString().contains('Dio')) {
        try {
          final response = (e as dynamic).response;
          if (response != null && response.data != null) {
            // gRPC-Gateway suele devolver { "message": "...", "code": ... }
            if (response.data is Map && response.data['message'] != null) {
              userFriendlyError = response.data['message'];
            }
          }
        } catch (_) {}
      }

      setState(() {
        _messages.removeWhere((m) => m.type == _ChatBubbleType.loading);
        _messages.add(_ChatMessage(
          type: _ChatBubbleType.error,
          text: "⚠️ $userFriendlyError",
        ));
        _isAnalyzing = false;
      });
    }
    _scrollToBottom();
  }

  Widget _buildBotMessage(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(left: 12, bottom: 4, right: 8),
            decoration: BoxDecoration(
              color: amarilloVainilla,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: doradoPastel, width: 1),
            ),
            child: const Icon(Icons.wine_bar_rounded, size: 16, color: vinoPastel),
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(top: 6, bottom: 6, right: 60),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(color: doradoPastel, width: 1),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: vinoOscuro,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(left: 12, bottom: 4, right: 8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red[200]!, width: 1),
            ),
            child: Icon(Icons.error_outline, size: 16, color: Colors.red[400]),
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(top: 6, bottom: 6, right: 60),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(color: Colors.red[200]!, width: 1),
              ),
              child: Text(
                text,
                style: TextStyle(fontSize: 13, color: Colors.red[700], height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBubble(File image) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(top: 6, bottom: 6, right: 16, left: 60),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: doradoPastel, width: 1),
          boxShadow: [
            BoxShadow(
              color: vinoOscuro.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(
            image,
            width: 220,
            height: 220,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(left: 12, bottom: 4, right: 8),
            decoration: BoxDecoration(
              color: amarilloVainilla,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: doradoPastel, width: 1),
            ),
            child: const Icon(Icons.wine_bar_rounded, size: 16, color: vinoPastel),
          ),
          Container(
            margin: const EdgeInsets.only(top: 6, bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: doradoPastel, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Analizando imagen",
                  style: TextStyle(
                    fontSize: 13,
                    color: vinoOscuro.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.8,
                    color: vinoPastel.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageWidget(_ChatMessage msg) {
    switch (msg.type) {
      case _ChatBubbleType.bot:
        return _buildBotMessage(msg.text ?? '');
      case _ChatBubbleType.image:
        return _buildImageBubble(msg.imageFile!);
      case _ChatBubbleType.loading:
        return _buildTypingIndicator();
      case _ChatBubbleType.error:
        return _buildErrorMessage(msg.text ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cremaClaro,
      appBar: AppBar(
        backgroundColor: cremaClaro,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: vinoOscuro,
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: amarilloVainilla,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: doradoPastel, width: 1),
              ),
              child: const Icon(Icons.wine_bar_rounded, size: 18, color: vinoPastel),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Asistente IA",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: vinoOscuro,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  "Vinoteca",
                  style: TextStyle(
                    fontSize: 11,
                    color: vinoOscuro.withOpacity(0.5),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: doradoPastel),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageWidget(_messages[index]),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: doradoPastel, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _takePhoto,
                      icon: const Icon(Icons.camera_alt_outlined, size: 20),
                      label: const Text(
                        "Tomar foto",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: vinoPastel,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _pickFromGallery,
                      icon: const Icon(Icons.photo_library_outlined, size: 20),
                      label: const Text(
                        "Galería",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: doradoPastel,
                        foregroundColor: vinoOscuro,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vision_provider.dart';
import '../providers/chat_history_provider.dart'; 

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  static const Color vinoOscuro = Color(0xFF6E3B47);
  static const Color vinoPastel = Color(0xFF8C4A5A);
  static const Color amarilloVainilla = Color(0xFFF3E5AB);
  static const Color doradoPastel = Color(0xFFE6D3A3);
  static const Color cremaClaro = Color(0xFFF8F5F0);

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _processImage(XFile pickedFile) async {
    final imageFile = File(pickedFile.path);

    ref.read(chatHistoryProvider.notifier).addImageMessage(imageFile);

    ref.read(chatHistoryProvider.notifier).addLoadingMessage();
    _scrollToBottom();

    try {
      final bytes = await pickedFile.readAsBytes();
      await ref
          .read(visionProvider.notifier)
          .analyzeImage(pickedFile.name, bytes);

      final visionState = ref.read(visionProvider);

      if (visionState.error != null) {
        ref
            .read(chatHistoryProvider.notifier)
            .addErrorMessage("Error al analizar: ${visionState.error}");
      } else if (visionState.result != null) {
        final wine = visionState.result!.wineData;
        ref.read(chatHistoryProvider.notifier).addBotMessage(
              "¡Análisis completado!\n\n"
              "Marca: ${wine.brand}\n"
              "Cepa/Variedad: ${wine.cepaVariedad}\n"
              "Año: ${wine.vintageYear}",
            );
      }
    } catch (e) {
      ref
          .read(chatHistoryProvider.notifier)
          .addErrorMessage("Error inesperado: $e");
    }

    _scrollToBottom();
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
              color: const Color(0xFFFFEBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFCCCC), width: 1),
            ),
            child: const Icon(Icons.error_outline_rounded,
                size: 16, color: Colors.redAccent),
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(top: 6, bottom: 6, right: 60),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                ),
                border:
                    Border.all(color: const Color(0xFFFFCCCC), width: 1),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.redAccent,
                  height: 1.4,
                ),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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


  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatHistoryProvider);
    final visionState = ref.watch(visionProvider);
    final isLoading = visionState.isLoading ||
        messages.any((m) => m.type == ChatMessageType.loading);

    ref.listen(chatHistoryProvider, (_, __) => _scrollToBottom());

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
              child: const Icon(Icons.wine_bar_rounded,
                  size: 18, color: vinoPastel),
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
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep_outlined,
                size: 20, color: vinoOscuro.withOpacity(0.5)),
            tooltip: "Limpiar chat",
            onPressed: isLoading
                ? null
                : () {
                    ref.read(chatHistoryProvider.notifier).clearHistory();
                  },
          ),
        ],
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
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                switch (msg.type) {
                  case ChatMessageType.bot:
                    return _buildBotMessage(msg.text ?? "");
                  case ChatMessageType.image:
                    return _buildImageBubble(msg.image!);
                  case ChatMessageType.loading:
                    return _buildTypingIndicator();
                  case ChatMessageType.error:
                    return _buildErrorMessage(msg.text ?? "");
                }
              },
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
                // Botón galería
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : _pickFromGallery,
                      icon: const Icon(Icons.photo_library_outlined, size: 19),
                      label: const Text(
                        "Galería",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: vinoPastel,
                        side: BorderSide(color: vinoPastel, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Botón cámara
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _takePhoto,
                      icon: const Icon(Icons.camera_alt_outlined, size: 20),
                      label: const Text(
                        "Tomar foto",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
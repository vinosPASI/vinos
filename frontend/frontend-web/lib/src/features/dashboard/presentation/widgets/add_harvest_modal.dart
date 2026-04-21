import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/utils/web_file_picker.dart';
import '../providers/dashboard_providers.dart';

/// Modal para añadir una nueva cosecha.
/// Flujo: Seleccionar imagen → Upload + VisionService → Formulario pre-rellenado → Guardar.
class AddHarvestModal extends ConsumerStatefulWidget {
  const AddHarvestModal({super.key});

  @override
  ConsumerState<AddHarvestModal> createState() => _AddHarvestModalState();
}

class _AddHarvestModalState extends ConsumerState<AddHarvestModal> {
  final _brandController = TextEditingController();
  final _cepaController = TextEditingController();
  final _yearController = TextEditingController();
  final _volumeController = TextEditingController();
  String? _selectedFileName;

  @override
  void dispose() {
    _brandController.dispose();
    _cepaController.dispose();
    _yearController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  Future<void> _pickAndAnalyzeImage() async {
    try {
      final result = await WebFilePicker.pickFile(accept: 'image/*');

      if (result != null) {
        setState(() => _selectedFileName = result.name);
        ref.read(analyzeLabelProvider.notifier).startAnalysis(result.name, result.bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivo: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _onSave() {
    // Guardar cosecha (mock por ahora)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cosecha "${_brandController.text}" guardada exitosamente.'),
        backgroundColor: Colors.green[700],
      ),
    );
    ref.read(analyzeLabelProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios del análisis para pre-rellenar campos
    ref.listen(analyzeLabelProvider, (previous, next) {
      if (next.status == AnalysisStatus.success && next.result != null) {
        final data = next.result!.wineData;
        _brandController.text = data.brand;
        _cepaController.text = data.cepaVariedad;
        _yearController.text = data.vintageYear > 0 ? data.vintageYear.toString() : '';
        _volumeController.text = data.volumeContent;
      }
    });

    final analysisState = ref.watch(analyzeLabelProvider);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Añadir Cosecha',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.wineSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(analyzeLabelProvider.notifier).reset();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Sube una foto de la etiqueta y la IA extraerá los datos automáticamente.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Zona de selección de imagen
              _buildImageSelector(analysisState),
              const SizedBox(height: 24),

              // Estado de análisis
              if (analysisState.status == AnalysisStatus.uploading ||
                  analysisState.status == AnalysisStatus.analyzing)
                _buildLoadingIndicator(analysisState),

              if (analysisState.status == AnalysisStatus.error)
                _buildErrorBanner(analysisState.errorMessage ?? 'Error desconocido'),

              // Formulario (visible siempre, se pre-rellena con éxito)
              const SizedBox(height: 8),
              _buildFormField('Marca / Bodega', _brandController, Icons.local_bar_outlined),
              const SizedBox(height: 12),
              _buildFormField('Cepa / Variedad', _cepaController, Icons.eco_outlined),
              const SizedBox(height: 12),
              _buildFormField('Año de Vendimia', _yearController, Icons.calendar_today_outlined, isNumber: true),
              const SizedBox(height: 12),
              _buildFormField('Volumen', _volumeController, Icons.straighten_outlined),
              const SizedBox(height: 24),

              // OCR Raw text (si disponible)
              if (analysisState.status == AnalysisStatus.success &&
                  analysisState.result != null &&
                  analysisState.result!.rawOcrText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cream.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.sand.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.document_scanner_outlined, size: 14, color: AppColors.winePrimary),
                          const SizedBox(width: 6),
                          Text('Texto OCR Detectado', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.winePrimary)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        analysisState.result!.rawOcrText,
                        style: TextStyle(fontSize: 11, color: Colors.grey[700], fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),

              // Botón Guardar
              ElevatedButton(
                onPressed: _brandController.text.isNotEmpty ? _onSave : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.winePrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Guardar Cosecha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSelector(AnalyzeLabelState state) {
    return GestureDetector(
      onTap: state.status == AnalysisStatus.uploading || state.status == AnalysisStatus.analyzing
          ? null
          : _pickAndAnalyzeImage,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedFileName != null ? AppColors.winePrimary : AppColors.sand,
            width: _selectedFileName != null ? 2 : 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _selectedFileName != null ? Icons.check_circle_outline : Icons.cloud_upload_outlined,
                size: 36,
                color: _selectedFileName != null ? AppColors.winePrimary : Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                _selectedFileName ?? 'Haz clic para seleccionar una imagen de etiqueta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _selectedFileName != null ? AppColors.wineSecondary : Colors.grey[500],
                  fontSize: 13,
                  fontWeight: _selectedFileName != null ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (_selectedFileName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Toca para cambiar', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(AnalyzeLabelState state) {
    final message = state.status == AnalysisStatus.uploading
        ? 'Subiendo imagen...'
        : 'Analizando etiqueta con IA...';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.winePrimary,
            ),
          ),
          const SizedBox(width: 12),
          Text(message, style: TextStyle(color: AppColors.wineSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.winePrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fuzzy/fuzzy.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/utils/web_file_picker.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventario_providers.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedEntityType = 'lote_vendimia';
  String? _selectedCSVName;

  final List<String> _entityTypes = [
    'lote_vendimia',
    'insumo',
    'producto_terminado',
    'movimiento',
  ];

  Color _getStatusColor(StockStatus status) {
    switch (status) {
      case StockStatus.red: return Colors.redAccent;
      case StockStatus.amber: return Colors.amber;
      case StockStatus.green: return Colors.greenAccent;
    }
  }

  String _getStatusLabel(StockStatus status) {
    switch (status) {
      case StockStatus.red: return 'Crítico';
      case StockStatus.amber: return 'Bajo';
      case StockStatus.green: return 'Normal';
    }
  }

  Future<void> _pickCSVAndImport() async {
    try {
      final result = await WebFilePicker.pickFile(accept: '.csv');

      if (result != null) {
        setState(() => _selectedCSVName = result.name);
        ref.read(importCSVProvider.notifier).startImport(result.name, result.bytes, _selectedEntityType);
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

  @override
  Widget build(BuildContext context) {
    // Escuchar resultado de importación
    ref.listen(importCSVProvider, (previous, next) {
      if (next.status == ImportStatus.success && next.result != null) {
        final r = next.result!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              r.success
                  ? '✅ Importación exitosa: ${r.insertedRows} filas insertadas.'
                  : '⚠️ Importación con errores: ${r.errors.length} problemas encontrados.',
            ),
            backgroundColor: r.success ? Colors.green[700] : Colors.orange[700],
            duration: const Duration(seconds: 4),
          ),
        );
      }
      if (next.status == ImportStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${next.errorMessage}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    final importState = ref.watch(importCSVProvider);
    final inventoryAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Zona de importación CSV
                        _buildImportSection(importState),
                        const SizedBox(height: 32),
                        // Buscador
                        _buildSearchBar(),
                        const SizedBox(height: 24),
                        // Tabla de inventario
                        _buildInventoryTable(inventoryAsync),
                      ],
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

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.wineSecondary,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Vinoteca Intelligence", 
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const Text("SOMMELIER ELITE PREMIUM", 
            style: TextStyle(color: AppColors.sand, fontSize: 10, letterSpacing: 1.2)),
          const SizedBox(height: 48),
          _sidebarItem(Icons.grid_view_rounded, "PANEL DE CONTROL", onTap: () {
            context.go('/dashboard');
          }),
          _sidebarItem(Icons.inventory_2_outlined, "INVENTARIO", active: true),
          _sidebarItem(Icons.analytics_outlined, "ANALÍTICA"),
          _sidebarItem(Icons.trending_up_rounded, "PREDICCIONES"),
          _sidebarItem(Icons.settings_outlined, "AJUSTES"),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, {bool active = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: active ? AppColors.sand : Colors.white38, size: 20),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(
              color: active ? Colors.white : Colors.white38, 
              fontSize: 13, 
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              letterSpacing: 1.0
            )),
            if (active) ...[
              const Spacer(),
              Container(width: 2, height: 20, color: AppColors.sand),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Gestión de Inventario", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.wineSecondary)),
          Icon(Icons.search, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildImportSection(ImportCSVState importState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.upload_file_rounded, color: AppColors.winePrimary, size: 22),
              const SizedBox(width: 10),
              const Text("Importar Datos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.wineSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          Text("Sube un archivo CSV para ingestar datos al sistema.", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            children: [
              // Dropdown entity_type
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.sand),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedEntityType,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: AppColors.winePrimary),
                      items: _entityTypes.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedEntityType = val!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Dropzone / Botón
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: importState.status == ImportStatus.uploading || importState.status == ImportStatus.importing
                      ? null
                      : _pickCSVAndImport,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedCSVName != null ? AppColors.winePrimary : AppColors.sand,
                        width: _selectedCSVName != null ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (importState.status == ImportStatus.uploading || importState.status == ImportStatus.importing) ...[
                          SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.winePrimary),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            importState.status == ImportStatus.uploading ? 'Subiendo...' : 'Importando...',
                            style: TextStyle(color: AppColors.wineSecondary, fontSize: 13),
                          ),
                        ] else ...[
                          Icon(
                            _selectedCSVName != null ? Icons.check_circle_outline : Icons.cloud_upload_outlined,
                            color: _selectedCSVName != null ? AppColors.winePrimary : Colors.grey[400],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedCSVName ?? 'Seleccionar archivo CSV',
                            style: TextStyle(
                              color: _selectedCSVName != null ? AppColors.wineSecondary : Colors.grey[500],
                              fontSize: 13,
                              fontWeight: _selectedCSVName != null ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Resultado de importación
          if (importState.status == ImportStatus.success && importState.result != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: importState.result!.success ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: importState.result!.success ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        importState.result!.success ? Icons.check_circle : Icons.warning_amber_rounded,
                        color: importState.result!.success ? Colors.green[700] : Colors.orange[700],
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        importState.result!.success
                            ? '${importState.result!.insertedRows} filas insertadas correctamente'
                            : '${importState.result!.errors.length} errores encontrados',
                        style: TextStyle(
                          color: importState.result!.success ? Colors.green[700] : Colors.orange[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (importState.result!.errors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...importState.result!.errors.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• Fila ${e.row ?? '?'}: ${e.field} — ${e.message}',
                        style: TextStyle(color: Colors.orange[800], fontSize: 11),
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() {}),
        decoration: InputDecoration(
          hintText: "Buscar insumos (Malbec, Corcho, etc... tolerante a errores)",
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.auto_awesome, color: AppColors.winePrimary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildInventoryTable(AsyncValue<List<InventoryItem>> inventoryAsync) {
    return inventoryAsync.when(
      data: (items) {
        List<InventoryItem> displayList = items;
        final query = _searchController.text;
        if (query.isNotEmpty) {
          final fuse = Fuzzy<InventoryItem>(
            items,
            options: FuzzyOptions(
              keys: [
                WeightedKey(name: 'name', getter: (i) => i.name, weight: 1.0),
                WeightedKey(name: 'type', getter: (i) => i.type, weight: 0.5),
              ],
              threshold: 0.3,
            ),
          );
          displayList = fuse.search(query).map((r) => r.item).toList();
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.cream.withOpacity(0.5)),
              columns: const [
                DataColumn(label: Text("STATUS", style: TextStyle(color: AppColors.wineSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                DataColumn(label: Text("NOMBRE", style: TextStyle(color: AppColors.wineSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                DataColumn(label: Text("TIPO", style: TextStyle(color: AppColors.wineSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                DataColumn(label: Text("CANTIDAD", style: TextStyle(color: AppColors.wineSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                DataColumn(label: Text("UNIDAD", style: TextStyle(color: AppColors.wineSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
              ],
              rows: displayList.map((item) => DataRow(
            cells: [
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(_getStatusLabel(item.status), style: TextStyle(color: _getStatusColor(item.status), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              DataCell(Text(item.name, style: const TextStyle(color: AppColors.wineSecondary, fontWeight: FontWeight.bold, fontSize: 13))),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.sand.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(item.typeLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                ),
              ),
              DataCell(Text(
                item.quantity.toString(),
                style: TextStyle(
                  color: item.quantity <= 100 ? Colors.redAccent : AppColors.wineSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              )),
              DataCell(Text(item.unit, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
            ],
          )).toList(),
        ),
      ),
    );
      },
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: CircularProgressIndicator(color: AppColors.winePrimary),
      )),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text("Error al cargar inventario: $err", style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}

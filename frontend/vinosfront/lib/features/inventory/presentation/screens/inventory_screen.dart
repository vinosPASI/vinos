import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventario_providers.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const Color vinoOscuro       = Color(0xFF6E3B47);
  static const Color vinoPastel       = Color(0xFF8C4A5A);
  static const Color amarilloVainilla = Color(0xFFF3E5AB);
  static const Color doradoPastel     = Color(0xFFE6D3A3);
  static const Color cremaClaro       = Color(0xFFF8F5F0);

  static const _categories = [
    ('todos',              'Todos',     Icons.grid_view_rounded),
    ('lote_vendimia',      'Vendimia',  Icons.local_florist_outlined),
    ('insumo',             'Insumos',   Icons.inventory_2_outlined),
    ('producto_terminado', 'Productos', Icons.wine_bar_rounded),
  ];

  Color _statusColor(StockStatus s) => switch (s) {
    StockStatus.red   => const Color(0xFFE53935),
    StockStatus.amber => const Color(0xFFFB8C00),
    StockStatus.green => const Color(0xFF43A047),
  };

  String _statusLabel(StockStatus s) => switch (s) {
    StockStatus.red   => 'Crítico',
    StockStatus.amber => 'Bajo',
    StockStatus.green => 'Normal',
  };

  List<InventoryItem> _filter(List<InventoryItem> items) {
    if (_searchQuery.isEmpty) return items;
    final q = _searchQuery.toLowerCase();
    return items
        .where((i) =>
            i.name.toLowerCase().contains(q) ||
            i.sku.toLowerCase().contains(q) ||
            i.warehouse.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final allItems         = ref.watch(inventoryListProvider);
    final stats            = ref.watch(inventoryStatsProvider);
    final displayItems     = _filter(allItems);

    return Scaffold(
      backgroundColor: cremaClaro,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatsStrip(stats),
          _buildCategoryChips(selectedCategory),
          _buildSearchBar(),
          Expanded(
            child: displayItems.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: displayItems.length,
                    itemBuilder: (_, i) => _buildItemCard(displayItems[i]),
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: cremaClaro,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
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
            child: const Icon(Icons.inventory_2_outlined,
                size: 18, color: vinoPastel),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Inventario",
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
    );
  }

  Widget _buildStatsStrip(Map<String, int> stats) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          _statChip('Total',   stats['total']!,   vinoOscuro,             Icons.grid_view_rounded),
          _statDivider(),
          _statChip('Normal',  stats['normal']!,  const Color(0xFF43A047), Icons.check_circle_outline),
          _statDivider(),
          _statChip('Bajo',    stats['bajo']!,    const Color(0xFFFB8C00), Icons.warning_amber_outlined),
          _statDivider(),
          _statChip('Crítico', stats['critico']!, const Color(0xFFE53935), Icons.error_outline_rounded),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(
        width: 1,
        height: 32,
        color: doradoPastel,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );

  Widget _statChip(String label, int value, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 3),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: vinoOscuro.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(String selected) {
    return Container(
      height: 52,
      color: cremaClaro,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: _categories.map((cat) {
          final (value, label, icon) = cat;
          final isActive = selected == value;
          return GestureDetector(
            onTap: () =>
                ref.read(selectedCategoryProvider.notifier).state = value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? vinoPastel : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? vinoPastel : doradoPastel,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon,
                      size: 14,
                      color: isActive ? Colors.white : vinoPastel),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : vinoOscuro,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(fontSize: 14, color: vinoOscuro),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, SKU o almacén...',
          hintStyle:
              TextStyle(color: vinoOscuro.withOpacity(0.35), fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded,
              color: vinoPastel.withOpacity(0.7), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded,
                      size: 18, color: vinoPastel.withOpacity(0.6)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: doradoPastel, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: doradoPastel, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: vinoPastel, width: 1.8),
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(InventoryItem item) {
    final color = _statusColor(item.status);
    final label = _statusLabel(item.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: doradoPastel, width: 1),
        boxShadow: [
          BoxShadow(
            color: vinoOscuro.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: amarilloVainilla,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: doradoPastel, width: 1),
                  ),
                  child: Icon(_categoryIcon(item.category),
                      size: 18, color: vinoPastel),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: vinoOscuro,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.sku,
                        style: TextStyle(
                          fontSize: 11,
                          color: vinoOscuro.withOpacity(0.45),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: color.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStockBar(item),
            const SizedBox(height: 10),
            Row(
              children: [
                _stockInfo('Stock Real', item.realStock.toString()),
                const SizedBox(width: 16),
                _stockInfo('Stock Neto', item.netStock.toString(),
                    highlight: item.status == StockStatus.red),
                const Spacer(),
                Icon(Icons.store_outlined,
                    size: 13, color: vinoOscuro.withOpacity(0.4)),
                const SizedBox(width: 4),
                Text(
                  item.warehouse,
                  style: TextStyle(
                    fontSize: 11,
                    color: vinoOscuro.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockBar(InventoryItem item) {
    final ratio = item.realStock == 0
        ? 0.0
        : (item.netStock / item.realStock).clamp(0.0, 1.0);
    final color = _statusColor(item.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${(ratio * 100).toStringAsFixed(0)}% disponible',
          style: TextStyle(
            fontSize: 10,
            color: vinoOscuro.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _stockInfo(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: vinoOscuro.withOpacity(0.45),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: highlight ? const Color(0xFFE53935) : vinoOscuro,
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 52, color: vinoOscuro.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            'Sin resultados',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: vinoOscuro.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Probá con otro término de búsqueda',
            style: TextStyle(
              fontSize: 12,
              color: vinoOscuro.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) => switch (category) {
        'lote_vendimia'      => Icons.local_florist_outlined,
        'insumo'             => Icons.inventory_2_outlined,
        'producto_terminado' => Icons.wine_bar_rounded,
        'movimiento'         => Icons.swap_horiz_rounded,
        _                    => Icons.category_outlined,
      };
}
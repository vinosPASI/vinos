import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_providers.dart';
import '../theme/app_colors.dart';

class SharedSidebar extends ConsumerWidget {
  final String activePage;

  const SharedSidebar({super.key, required this.activePage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 260,
      color: AppColors.vinoOscuro,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Vinoteca Intelligence", 
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const Text("SOMMELIER ELITE PREMIUM", 
            style: TextStyle(color: AppColors.doradoPastel, fontSize: 10, letterSpacing: 1.2)),
          const SizedBox(height: 48),
          
          _sidebarItem(
            ref,
            Icons.grid_view_rounded, 
            "PANEL DE CONTROL", 
            'dashboard',
            activePage == 'dashboard'
          ),
          
          _sidebarItem(
            ref,
            Icons.inventory_2_rounded, 
            "INVENTARIO", 
            'detail',
            activePage == 'detail'
          ),
          
          _sidebarItem(ref, Icons.analytics_outlined, "ANALÍTICA", 'analytics', activePage == 'analytics'),
          _sidebarItem(ref, Icons.settings_outlined, "AJUSTES", 'settings', activePage == 'settings'),
          
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vinoPastel,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("AÑADIR COSECHA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(backgroundColor: AppColors.doradoPastel, child: Text("A", style: TextStyle(color: AppColors.vinoOscuro, fontWeight: FontWeight.bold))),
            title: const Text("Angel", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: const Text("ADMINISTRADOR", style: TextStyle(color: Colors.white38, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(WidgetRef ref, IconData icon, String title, String target, bool active) {
    return InkWell(
      onTap: () => ref.read(navigationProvider.notifier).state = target,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: active ? AppColors.doradoPastel : Colors.white38, size: 20),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(
              color: active ? Colors.white : Colors.white38, 
              fontSize: 13, 
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              letterSpacing: 1.0
            )),
            if (active) ...[
              const Spacer(),
              Container(width: 2, height: 20, color: AppColors.doradoPastel),
            ]
          ],
        ),
      ),
    );
  }
}

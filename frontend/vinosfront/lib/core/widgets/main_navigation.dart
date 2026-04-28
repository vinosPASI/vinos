import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vinosfront/core/theme/app_theme.dart';
import 'package:vinosfront/core/utils/screens_dimension.dart';

class MainNavigation extends StatelessWidget {
  final Widget child;

  const MainNavigation({super.key, required this.child});

  int _getIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/chat')) return 1;
    if (location.startsWith('/notifications')) return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/chat');
        break;
      case 2:
        context.go('/notifications');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ScreenDimensions.of(context);
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _getIndex(location);

    return Scaffold(
      backgroundColor: VinotecaColors.cremaClaro,
      body: child,
      bottomNavigationBar: _BottomNav(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
        s: s,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final ScreenDimensions s;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.s,
  });

  static const _items = [
    _NavItem(icon: Icons.home_outlined,       activeIcon: Icons.home,              label: 'Inicio'),
    _NavItem(icon: Icons.camera_alt_outlined, activeIcon: Icons.camera_alt,        label: 'IA'),
    _NavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications,  label: 'Alertas'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VinotecaColors.vinoPastel,
        boxShadow: [
          BoxShadow(
            color: VinotecaColors.vinoOscuro.withOpacity(0.15),
            blurRadius: s.wp(2),
            offset: Offset(0, -s.hp(0.2)),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: s.hp(8),
          child: Row(
            children: List.generate(_items.length, (index) {
              return Expanded(
                child: _NavButton(
                  item: _items[index],
                  isSelected: currentIndex == index,
                  onTap: () => onTap(index),
                  s: s,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final ScreenDimensions s;

  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: s.wp(3.5),
              vertical: s.hp(0.5),
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? VinotecaColors.vinoOscuro.withOpacity(0.35)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(s.wp(4)),
            ),
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected
                  ? VinotecaColors.doradoPastel
                  : Colors.white70,
              size: s.wp(5.8),
            ),
          ),

          SizedBox(height: s.hp(0.4)),

          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: s.sp(10.5),
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected
                  ? VinotecaColors.doradoPastel
                  : Colors.white70,
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
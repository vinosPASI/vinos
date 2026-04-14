import 'package:flutter/material.dart';
import 'package:vinosfront/core/theme/app_theme.dart';
import 'package:vinosfront/core/utils/screens_dimension.dart';
import 'package:vinosfront/features/notifications/data/notification_mock_data.dart';
import 'package:vinosfront/features/notifications/domain/notification_model.dart';
import 'package:vinosfront/features/notifications/presentation/widgets/notification_item.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _filtro = 'todas';

  List<NotificationModel> get _notificaciones =>
      NotificationMockData.notifications;

  List<NotificationModel> get _notificacionesFiltradas {
    if (_filtro == 'noLeidas') {
      return _notificaciones.where((n) => !n.isRead).toList();
    }
    return _notificaciones;
  }

  int get _unreadCount => _notificaciones.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final s = ScreenDimensions.of(context);

    return Scaffold(
      backgroundColor: VinotecaColors.cremaClaro,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(s),
            _buildFilterRow(s),
            Expanded(child: _buildList(s)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ScreenDimensions s) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: s.wp(4.8),
        vertical: s.hp(2),
      ),
      child: Row(
        children: [
          Text(
            'Notificaciones',
            style: TextStyle(
              fontSize: s.sp(22),
              fontWeight: FontWeight.w700,
              color: VinotecaColors.vinoOscuro,
              letterSpacing: 0.2,
            ),
          ),
          if (_unreadCount > 0) ...[
            SizedBox(width: s.wp(2.5)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: s.wp(2.2),
                vertical: s.hp(0.35),
              ),
              decoration: BoxDecoration(
                color: VinotecaColors.vinoPastel,
                borderRadius: BorderRadius.circular(s.wp(3)),
              ),
              child: Text(
                '$_unreadCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: s.sp(11),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildFilterRow(ScreenDimensions s) {
    return Padding(
      padding: EdgeInsets.only(
        left: s.wp(4.8),
        right: s.wp(4.8),
        bottom: s.hp(1.2),
      ),
      child: Row(
        children: [
          _FilterChip(
            label: 'Todas',
            isSelected: _filtro == 'todas',
            onTap: () => setState(() => _filtro = 'todas'),
            s: s,
          ),
          SizedBox(width: s.wp(2.5)),
          _FilterChip(
            label: 'No leídas',
            isSelected: _filtro == 'noLeidas',
            onTap: () => setState(() => _filtro = 'noLeidas'),
            s: s,
          ),
        ],
      ),
    );
  }


  Widget _buildList(ScreenDimensions s) {
    if (_notificacionesFiltradas.isEmpty) return _EmptyState(s: s);

    return ListView.builder(
      padding: EdgeInsets.only(top: s.hp(0.5)),
      itemCount: _notificacionesFiltradas.length,
      itemBuilder: (context, index) {
        final n = _notificacionesFiltradas[index];
        return NotificationItem(
          title: n.title,
          description: n.description,
          time: n.time,
          icon: n.icon,
          isRead: n.isRead,
        );
      },
    );
  }
}


class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ScreenDimensions s;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: s.wp(4.0),
          vertical: s.hp(0.7),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? VinotecaColors.vinoPastel
              : VinotecaColors.amarilloVainilla.withOpacity(0.6),
          borderRadius: BorderRadius.circular(s.wp(5)),
          border: Border.all(
            color: isSelected
                ? VinotecaColors.vinoOscuro
                : VinotecaColors.doradoPastel,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: s.sp(12.5),
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : VinotecaColors.vinoOscuro,
          ),
        ),
      ),
    );
  }
}


class _EmptyState extends StatelessWidget {
  final ScreenDimensions s;
  const _EmptyState({required this.s});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: s.wp(16),
            color: VinotecaColors.doradoPastel,
          ),
          SizedBox(height: s.hp(2)),
          Text(
            'Sin notificaciones',
            style: TextStyle(
              fontSize: s.sp(15),
              fontWeight: FontWeight.w600,
              color: VinotecaColors.vinoOscuro,
            ),
          ),
          SizedBox(height: s.hp(0.8)),
          Text(
            'Cuando tengas novedades,\naparecerán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: s.sp(13),
              color: VinotecaColors.vinoOscuro.withOpacity(0.5),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
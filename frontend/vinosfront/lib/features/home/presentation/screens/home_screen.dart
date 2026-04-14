import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vinosfront/core/theme/app_theme.dart';
import 'package:vinosfront/core/utils/screens_dimension.dart';
import 'package:vinosfront/features/home/data/home_mock_data.dart';
import 'package:vinosfront/features/home/domain/activity_model.dart';
import 'package:vinosfront/features/home/domain/dashboard_card_model.dart';
import 'package:vinosfront/router/app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = ScreenDimensions.of(context);

    // Consume el mock — cuando haya repositorio real, solo cambia esta línea
    final cards    = HomeMockData.dashboardCards;
    final activity = HomeMockData.recentActivity;

    return Scaffold(
      backgroundColor: VinotecaColors.cremaClaro,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: s.wp(4.8),
            vertical: s.hp(2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(s),
              SizedBox(height: s.hp(2.5)),
              _buildDashboardGrid(cards, s),
              SizedBox(height: s.hp(3)),
              _buildSectionTitle('Accesos rápidos', s),
              SizedBox(height: s.hp(1.5)),
              _buildQuickActions(context, s),
              SizedBox(height: s.hp(3)),
              _buildSectionTitle('Actividad reciente', s),
              SizedBox(height: s.hp(1.2)),
              _buildActivity(activity, s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ScreenDimensions s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vinoteca ML',
          style: TextStyle(
            fontSize: s.sp(24),
            fontWeight: FontWeight.w800,
            color: VinotecaColors.vinoOscuro,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: s.hp(0.5)),
        Text(
          'Bienvenido, gestioná tu inventario inteligente',
          style: TextStyle(
            fontSize: s.sp(13.5),
            color: VinotecaColors.vinoOscuro.withOpacity(0.55),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardGrid(List<DashboardCardModel> cards, ScreenDimensions s) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _DashboardCard(data: cards[0], s: s)),
            SizedBox(width: s.wp(2.5)),
            Expanded(child: _DashboardCard(data: cards[1], s: s)),
          ],
        ),
        SizedBox(height: s.hp(1.2)),
        Row(
          children: [
            Expanded(child: _DashboardCard(data: cards[2], s: s)),
            SizedBox(width: s.wp(2.5)),
            Expanded(child: _DashboardCard(data: cards[3], s: s)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, ScreenDimensions s) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            title: 'IA Cámara',
            icon: Icons.camera_alt_outlined,
            onTap: () => context.goNamed(AppRoutes.chat),
            s: s,
          ),
        ),
        SizedBox(width: s.wp(2.5)),
        Expanded(
          child: _QuickAction(
            title: 'Notificaciones',
            icon: Icons.notifications_outlined,
            onTap: () => context.goNamed(AppRoutes.notifications),
            s: s,
          ),
        ),
      ],
    );
  }

  Widget _buildActivity(List<ActivityModel> items, ScreenDimensions s) {
    return Column(
      children: items.map((item) => _ActivityItem(data: item, s: s)).toList(),
    );
  }

  Widget _buildSectionTitle(String title, ScreenDimensions s) {
    return Text(
      title,
      style: TextStyle(
        fontSize: s.sp(17),
        fontWeight: FontWeight.w700,
        color: VinotecaColors.vinoOscuro,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final DashboardCardModel data;
  final ScreenDimensions s;
  const _DashboardCard({required this.data, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(s.wp(3.7)),
      decoration: BoxDecoration(
        color: VinotecaColors.amarilloVainilla,
        borderRadius: BorderRadius.circular(s.wp(3.7)),
        boxShadow: [
          BoxShadow(
            color: VinotecaColors.vinoOscuro.withOpacity(0.06),
            blurRadius: s.wp(1.6),
            offset: Offset(0, s.hp(0.28)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(s.wp(2)),
            decoration: BoxDecoration(
              color: VinotecaColors.vinoPastel.withOpacity(0.12),
              borderRadius: BorderRadius.circular(s.wp(2.5)),
            ),
            child: Icon(data.icon, color: VinotecaColors.vinoPastel, size: s.wp(5.5)),
          ),
          SizedBox(height: s.hp(1.2)),
          Text(
            data.value,
            style: TextStyle(fontSize: s.sp(22), fontWeight: FontWeight.w800, color: VinotecaColors.vinoOscuro),
          ),
          SizedBox(height: s.hp(0.4)),
          Text(
            data.title,
            style: TextStyle(fontSize: s.sp(12), color: VinotecaColors.vinoOscuro.withOpacity(0.6), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final ScreenDimensions s;
  const _QuickAction({required this.title, required this.icon, required this.onTap, required this.s});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: s.hp(1.8), horizontal: s.wp(3.7)),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: VinotecaColors.doradoPastel),
          borderRadius: BorderRadius.circular(s.wp(3.7)),
          boxShadow: [
            BoxShadow(
              color: VinotecaColors.vinoOscuro.withOpacity(0.04),
              blurRadius: s.wp(1.2),
              offset: Offset(0, s.hp(0.2)),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: VinotecaColors.vinoPastel, size: s.wp(6)),
            SizedBox(height: s.hp(0.8)),
            Text(
              title,
              style: TextStyle(fontSize: s.sp(12.5), fontWeight: FontWeight.w600, color: VinotecaColors.vinoOscuro),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final ActivityModel data;
  final ScreenDimensions s;
  const _ActivityItem({required this.data, required this.s});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: s.hp(1.2)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: s.hp(0.6)),
            child: Container(
              width: s.wp(2),
              height: s.wp(2),
              decoration: const BoxDecoration(color: VinotecaColors.vinoPastel, shape: BoxShape.circle),
            ),
          ),
          SizedBox(width: s.wp(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.text, style: TextStyle(fontSize: s.sp(13.5), fontWeight: FontWeight.w500, color: VinotecaColors.vinoOscuro)),
                SizedBox(height: s.hp(0.3)),
                Text(data.time, style: TextStyle(fontSize: s.sp(11.5), color: VinotecaColors.vinoOscuro.withOpacity(0.45))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
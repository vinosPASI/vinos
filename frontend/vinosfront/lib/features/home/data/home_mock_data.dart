import 'package:flutter/material.dart';
import '../domain/dashboard_card_model.dart';
import '../domain/activity_model.dart';

// Datos de prueba para desarrollo.
class HomeMockData {
  HomeMockData._();

  static const List<DashboardCardModel> dashboardCards = [
    DashboardCardModel(
      title: 'Stock Bajo',
      value: '12',
      icon: Icons.warning_amber_rounded,
    ),
    DashboardCardModel(
      title: 'Ventas Hoy',
      value: '85',
      icon: Icons.shopping_cart_outlined,
    ),
    DashboardCardModel(
      title: 'Predicción',
      value: '+35%',
      icon: Icons.trending_up_rounded,
    ),
    DashboardCardModel(
      title: 'Alertas',
      value: '5',
      icon: Icons.notifications_active_outlined,
    ),
  ];

  static const List<ActivityModel> recentActivity = [
    ActivityModel(
      text: 'Se detectó bajo stock en Malbec',
      time: 'Hace 5 min',
    ),
    ActivityModel(
      text: 'Nueva predicción generada',
      time: 'Hace 1 hora',
    ),
  ];
}
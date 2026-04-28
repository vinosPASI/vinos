import 'package:flutter/material.dart';

class AppColors {
  static const Color winePrimary = Color(0xFF8C4A5A);
  static const Color wineSecondary = Color(0xFF6E3B47);
  static const Color cream = Color(0xFFF3E5AB);
  static const Color sand = Color(0xFFE6D3A3);
  static const Color background = Color(0xFFF8F5F0);

  // Equivalencias para retrocompatibilidad con las pantallas UI
  static const Color cremaClaro = background;
  static const Color vinoPastel = winePrimary;
  static const Color vinoOscuro = wineSecondary;
  static const Color doradoPastel = sand;
  static const Color textoPrincipal = wineSecondary;
  static const Color textoSecundario = Colors.grey;

  AppColors._();
}

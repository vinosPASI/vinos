import 'package:flutter/material.dart';

class ScreenDimensions {
  final double width;
  final double height;

  const ScreenDimensions({required this.width, required this.height});

  factory ScreenDimensions.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return ScreenDimensions(width: size.width, height: size.height);
  }

  // Porcentaje del ancho de pantalla.
  double wp(double percent) => width * percent / 100;
  // Porcentaje del alto de pantalla.
  double hp(double percent) => height * percent / 100;
  // Factor de escala basado en 375 pt
  double get scaleFactor => (width / 375).clamp(0.85, 1.4);
  // Tamaño de fuente escalado al dispositivo.
  double sp(double size) => size * scaleFactor;
}
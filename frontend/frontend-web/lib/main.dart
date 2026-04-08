import 'package:flutter/material.dart';
import 'src/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  runApp(const VinotecaIntelligenceApp());
}

class VinotecaIntelligenceApp extends StatelessWidget {
  const VinotecaIntelligenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vinoteca Intelligence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF800020),
        scaffoldBackgroundColor: const Color(0xFF131313),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

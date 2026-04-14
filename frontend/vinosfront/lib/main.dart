import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const VinotecaApp());
}

class VinotecaApp extends StatelessWidget {
  const VinotecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vinoteca ML',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: _buildTheme(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: VinotecaColors.cremaClaro,

      colorScheme: ColorScheme.light(
        primary: VinotecaColors.vinoPastel,
        onPrimary: Colors.white,
        secondary: VinotecaColors.doradoPastel,
        onSecondary: VinotecaColors.vinoOscuro,
        surface: VinotecaColors.amarilloVainilla,
        onSurface: VinotecaColors.vinoOscuro,
      ),

      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: VinotecaColors.vinoOscuro,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          color: VinotecaColors.vinoOscuro,
        ),
        bodySmall: const TextStyle(
          color: Colors.black54,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VinotecaColors.vinoPastel,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: VinotecaColors.vinoPastel,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
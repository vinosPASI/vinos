import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/shared/theme/app_colors.dart';
import 'src/shared/providers/navigation_providers.dart';
import 'src/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'src/features/detail/presentation/screens/predictive_detail_screen.dart';

void main() {
  runApp(const ProviderScope(child: VinotecaIntelligenceApp()));
}

class VinotecaIntelligenceApp extends StatelessWidget {
  const VinotecaIntelligenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vinoteca Intelligence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.vinoPastel,
        scaffoldBackgroundColor: AppColors.cremaClaro,
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.textoPrincipal, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: AppColors.textoPrincipal),
        ),
      ),
      home: const MainNavigationEntry(),
    );
  }
}

class MainNavigationEntry extends ConsumerWidget {
  const MainNavigationEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(navigationProvider);

    switch (currentPage) {
      case 'detail':
        return const PredictiveDetailScreen();
      case 'dashboard':
      default:
        return const DashboardScreen();
    }
  }
}

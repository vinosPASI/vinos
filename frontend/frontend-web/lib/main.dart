import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_web/src/shared/router/app_router.dart';
import 'package:frontend_web/src/shared/theme/app_colors.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VINOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.winePrimary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Outfit',
      ),
      routerConfig: appRouter,
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

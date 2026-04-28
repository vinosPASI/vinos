import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vinosfront/core/widgets/main_navigation.dart';
import 'package:vinosfront/features/home/presentation/screens/home_screen.dart';
import 'package:vinosfront/features/camera_ia/presentation/screens/camera_screen.dart';
import 'package:vinosfront/features/notifications/presentation/screens/notification_screen.dart';
import 'package:vinosfront/features/auth/presentation/screens/login_screen.dart';
import 'package:vinosfront/features/auth/presentation/screens/register_screen.dart';
import 'package:vinosfront/features/inventory/presentation/screens/inventory_screen.dart';

abstract class AppRoutes {
  static const login         = '/login';
  static const register      = '/register';
  static const home          = '/home';
  static const chat          = '/chat';
  static const inventory     = '/inventory';
  static const notifications = '/notifications';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  debugLogDiagnostics: true,

  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFFF8F5F0),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wine_bar_outlined, size: 64, color: Color(0xFF8C4A5A)),
          const SizedBox(height: 16),
          const Text(
            'Página no encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6E3B47),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text(
              'Volver al inicio',
              style: TextStyle(color: Color(0xFF8C4A5A)),
            ),
          ),
        ],
      ),
    ),
  ),

  routes: [

    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),

    ShellRoute(
      builder: (context, state, child) => MainNavigation(child: child),
      routes: [

        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),

        GoRoute(
          path: AppRoutes.chat,
          name: 'chat',
          builder: (context, state) => const CameraScreen(),
        ),

        GoRoute(
          path: AppRoutes.inventory,
          name: 'inventory',
          builder: (context, state) => const InventoryScreen(),
        ),

        GoRoute(
          path: AppRoutes.notifications,
          name: 'notifications',
          builder: (context, state) => const NotificationScreen(),
        ),
      ],
    ),
  ],
);
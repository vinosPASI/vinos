import 'package:go_router/go_router.dart';
import 'package:frontend_web/src/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_web/src/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:frontend_web/src/features/inventory/presentation/screens/inventory_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/inventory',
      name: 'inventory',
      builder: (context, state) => const InventoryScreen(),
    ),
    GoRoute(
      path: '/',
      name: 'home',
      redirect: (context, state) => '/dashboard',
    ),
  ],
);

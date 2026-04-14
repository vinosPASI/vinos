import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend_web/src/features/auth/presentation/pages/login_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Home')),
      ),
    ),
  ],
);

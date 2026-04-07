import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Definimos el router como una constante global por ahora. 
final appRouter = GoRouter(
  initialLocation: '/',
  // Muestra logs de navegación en la consola.
  debugLogDiagnostics: true, 
  
  routes: [
    // Ruta Raíz
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Vinoteca - Home gRPC Ready'),
        ),
      ),
    ),
    
    // Aquí irán las rutas de las features (login, dashboard, etc.)
  ],

  // Manejo de error 404
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('404 - Página no encontrada', 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Volver al Inicio'),
          ),
        ],
      ),
    ),
  ),
);
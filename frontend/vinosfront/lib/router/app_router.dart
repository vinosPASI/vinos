import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/example/presentation/screens/camera_screen.dart';

// Definimos el router como una constante global por ahora. 
final appRouter = GoRouter(
  initialLocation: '/camera',
  // Muestra logs de navegación en la consola.
  debugLogDiagnostics: true, 
  
  routes: [
    // Ruta Raíz
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Vinoteca - Home gRPC Ready'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.push('/camera'),
                child: const Text('PROBAR CÁMARA [VM-51]'),
              ),
            ],
          ),
        ),
      ),
    ),
    
    // Ruta de la Cámara VM-51
    GoRoute(
      path: '/camera',
      name: 'camera',
      builder: (context, state) => const CameraScreen(),
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
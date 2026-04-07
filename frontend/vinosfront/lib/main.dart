import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; //Esta desde ahora para futura configuracion :)
import 'router/app_router.dart';

void main() {
  // Envolvemos en ProviderScope porque es requisito de Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //Usamos .router para habilitar GoRouter
    return MaterialApp.router(
      title: 'Vinoteca App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      // Conectamos nuestra configuración de rutas
      routerConfig: appRouter,
    );
  }
}
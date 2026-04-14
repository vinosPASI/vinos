import 'package:flutter_riverpod/flutter_riverpod.dart';

// Proveedor global para manejar la navegación entre pantallas
final navigationProvider = StateProvider<String>((ref) => 'dashboard');

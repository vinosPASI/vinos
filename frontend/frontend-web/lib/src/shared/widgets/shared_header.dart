import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SharedHeader extends StatelessWidget {
  final String title;

  const SharedHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Titulo dinámico
          Text(
            title, 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textoPrincipal)
          ),
          
          // Acciones de la derecha (Cava, Mercado, Perfil)
          Row(
            children: const [
              Text("Cava", style: TextStyle(color: AppColors.vinoPastel, fontWeight: FontWeight.bold, fontSize: 12)),
              SizedBox(width: 32),
              Text("Mercado", style: TextStyle(color: AppColors.textoSecundario, fontSize: 12)),
              SizedBox(width: 32),
              Text("Viñedos", style: TextStyle(color: AppColors.textoSecundario, fontSize: 12)),
              SizedBox(width: 32),
              Icon(Icons.search, color: AppColors.textoSecundario, size: 20),
              SizedBox(width: 24),
              Icon(Icons.person_outline, color: AppColors.vinoOscuro, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

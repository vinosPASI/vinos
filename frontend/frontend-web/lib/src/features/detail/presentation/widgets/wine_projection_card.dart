import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class WineProjectionCard extends StatelessWidget {
  final String projection;
  final int realStock;
  final int netStock;

  const WineProjectionCard({
    super.key, 
    required this.projection, 
    required this.realStock, 
    required this.netStock
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 720,
      decoration: BoxDecoration(
        color: AppColors.vinoOscuro,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.vinoOscuro.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                // Etiqueta de Proyección
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "PROYECCIÓN DE AGOTAMIENTO", // Traducido
                        style: TextStyle(
                          color: AppColors.doradoPastel.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        projection,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Imagen de la Botella
                Expanded(
                  flex: 8,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?q=80&w=2070&auto=format&fit=crop',
                    fit: BoxFit.contain,
                  ),
                ),
                
                const Spacer(),
                
                // Stats Inferiores
                Row(
                  children: [
                    _buildStat("STOCK REAL", realStock.toString(), "Unidades en sitio"),
                    Container(width: 1, height: 40, color: Colors.white10),
                    _buildStat("STOCK NETO", netStock.toString(), "Disponible para promesa"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, String sublabel) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            sublabel,
            style: TextStyle(color: AppColors.doradoPastel.withOpacity(0.6), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

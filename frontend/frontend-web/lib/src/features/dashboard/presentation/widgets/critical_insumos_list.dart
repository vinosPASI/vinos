import 'package:flutter/material.dart';

class CriticalInsumosList extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const CriticalInsumosList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            "Alerta de Insumos Críticos (ML Score)",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final score = (item['score'] as double) * 100;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                color: const Color(0xFF252525), // Slightly lighter charcoal
                child: ListTile(
                  leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  title: Text(item['name'], style: const TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Stock Neto: ${item['net_stock']}", 
                        style: TextStyle(color: Colors.white.withOpacity(0.5))),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: item['score'],
                        backgroundColor: Colors.white10,
                        color: score > 80 ? const Color(0xFF800020) : Colors.amber,
                      ),
                    ],
                  ),
                  trailing: Text("${score.toInt()}%", 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

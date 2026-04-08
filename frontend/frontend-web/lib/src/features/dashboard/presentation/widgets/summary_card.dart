import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? trend;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: const Color(0xFF1E1E1E), // Deep Charcoal
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: const Color(0xFF800020), size: 28), // Burgundy wine
                if (trend != null)
                  Text(
                    trend!,
                    style: TextStyle(
                      color: trend!.contains('+') ? Colors.green : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

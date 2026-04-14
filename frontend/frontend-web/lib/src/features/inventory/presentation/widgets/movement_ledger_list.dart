import 'package:flutter/material.dart';

class MovementLedgerList extends StatelessWidget {
  final List<Map<String, dynamic>> movements;

  const MovementLedgerList({super.key, required this.movements});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Historial de Movimientos (Ledger)",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movements.length,
          itemBuilder: (context, index) {
            final mov = movements[index];
            final isOut = mov['type'] == 'Remitido';
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                tileColor: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                leading: Icon(
                  isOut ? Icons.arrow_outward_rounded : Icons.call_received_rounded,
                  color: isOut ? Colors.redAccent : Colors.greenAccent,
                ),
                title: Text(mov['reference'], style: const TextStyle(color: Colors.white)),
                subtitle: Text(mov['date'], style: TextStyle(color: Colors.white.withOpacity(0.5))),
                trailing: Text(
                  "${isOut ? '-' : '+'}${mov['quantity']}",
                  style: TextStyle(
                    color: isOut ? Colors.redAccent : Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

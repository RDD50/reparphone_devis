import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;

  const StatusBadge({
    super.key,
    required this.label,
  });

  Color _background() {
    switch (label) {
      case 'En réparation':
        return Colors.blue.shade100;
      case 'En attente de pièce':
        return Colors.orange.shade100;
      case 'Terminé':
      case 'Payé':
        return Colors.green.shade100;
      case 'Livré':
        return Colors.grey.shade300;
      case 'Annulé':
      case 'Non payé':
        return Colors.red.shade100;
      case 'Acompte versé':
        return Colors.amber.shade100;
      default:
        return Colors.blueGrey.shade100;
    }
  }

  Color _foreground() {
    switch (label) {
      case 'En réparation':
        return Colors.blue.shade900;
      case 'En attente de pièce':
        return Colors.orange.shade900;
      case 'Terminé':
      case 'Payé':
        return Colors.green.shade900;
      case 'Livré':
        return Colors.grey.shade900;
      case 'Annulé':
      case 'Non payé':
        return Colors.red.shade900;
      case 'Acompte versé':
        return Colors.amber.shade900;
      default:
        return Colors.blueGrey.shade900;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _background(),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _foreground(),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

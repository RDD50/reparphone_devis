import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  Color _backgroundColor() {
    switch (status) {
      case 'En réparation':
        return Colors.blue.shade100;
      case 'En attente de pièce':
        return Colors.orange.shade100;
      case 'Terminé':
        return Colors.green.shade100;
      case 'Livré':
        return Colors.grey.shade300;
      case 'Annulé':
        return Colors.red.shade100;
      default:
        return Colors.blueGrey.shade100;
    }
  }

  Color _textColor() {
    switch (status) {
      case 'En réparation':
        return Colors.blue.shade900;
      case 'En attente de pièce':
        return Colors.orange.shade900;
      case 'Terminé':
        return Colors.green.shade900;
      case 'Livré':
        return Colors.grey.shade900;
      case 'Annulé':
        return Colors.red.shade900;
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
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _textColor(),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

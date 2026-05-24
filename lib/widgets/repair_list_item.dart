import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/repair.dart';
import 'status_badge.dart';

class RepairListItem extends StatelessWidget {
  final Repair repair;
  final VoidCallback onTap;

  const RepairListItem({
    super.key,
    required this.repair,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.phone_android),
        title: Text(
          '${repair.brand} ${repair.model}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${repair.id} • ${repair.clientName}'),
              const SizedBox(height: 5),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  StatusBadge(label: repair.status),
                  StatusBadge(label: repair.paymentInfo.status),
                ],
              ),
            ],
          ),
        ),
        trailing: Text(
          Formatters.money(repair.remainingDue),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

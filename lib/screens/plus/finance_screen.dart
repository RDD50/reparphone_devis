import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../models/app_data.dart';
import '../../models/repair.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/repair_list_item.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../repairs/repair_detail_screen.dart';

class FinanceScreen extends StatelessWidget {
  final AppData data;
  final Future<void> Function(AppData) onDataChanged;

  const FinanceScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  double get totalSales {
    return data.repairs.fold(0, (sum, repair) => sum + repair.totalPrice);
  }

  double get totalDeposits {
    return data.repairs.fold(0, (sum, repair) => sum + repair.deposit);
  }

  double get totalRemaining {
    return data.repairs.fold(0, (sum, repair) => sum + repair.remaining);
  }

  double get totalPaid {
    return data.repairs
        .where((repair) => repair.paymentInfo.status == 'Payé')
        .fold(0, (sum, repair) => sum + repair.totalPrice);
  }

  List<Repair> get unpaidRepairs {
    return data.repairs
        .where((repair) => repair.paymentInfo.status != 'Payé')
        .toList()
        .reversed
        .toList();
  }

  void _openRepair(BuildContext context, Repair repair) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepairDetailScreen(
          data: data,
          repair: repair,
          onDataChanged: onDataChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              StatCard(
                title: 'Total devis',
                value: Formatters.money(totalSales),
                icon: Icons.receipt_long,
              ),
              StatCard(
                title: 'Encaissé',
                value: Formatters.money(totalPaid),
                icon: Icons.payments,
                color: Colors.green,
              ),
              StatCard(
                title: 'Acomptes',
                value: Formatters.money(totalDeposits),
                icon: Icons.savings,
                color: Colors.blue,
              ),
              StatCard(
                title: 'Restant dû',
                value: Formatters.money(totalRemaining),
                icon: Icons.warning_amber,
                color: Colors.orange,
              ),
            ],
          ),
          const SectionHeader(title: 'Dossiers non payés'),
          if (unpaidRepairs.isEmpty)
            const EmptyStateCard(
              message: 'Aucun dossier non payé.',
              icon: Icons.check_circle_outline,
            )
          else
            ...unpaidRepairs.map(
              (repair) => RepairListItem(
                repair: repair,
                onTap: () => _openRepair(context, repair),
              ),
            ),
        ],
      ),
    );
  }
}

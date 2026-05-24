import 'package:flutter/material.dart';

import '../models/repair.dart';
import '../models/shop_settings.dart';
import '../widgets/status_badge.dart';
import 'repair_detail_screen.dart';

class RepairListScreen extends StatefulWidget {
  final List<Repair> repairs;
  final ShopSettings settings;
  final Future<void> Function(List<Repair>) onChanged;

  const RepairListScreen({
    super.key,
    required this.repairs,
    required this.settings,
    required this.onChanged,
  });

  @override
  State<RepairListScreen> createState() => _RepairListScreenState();
}

class _RepairListScreenState extends State<RepairListScreen> {
  late List<Repair> repairs;
  String selectedFilter = 'Toutes';

  @override
  void initState() {
    super.initState();
    repairs = List.of(widget.repairs);
  }

  List<Repair> get filteredRepairs {
    if (selectedFilter == 'Toutes') {
      return repairs;
    }

    return repairs.where((repair) => repair.status == selectedFilter).toList();
  }

  Future<void> _openDetail(Repair repair) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepairDetailScreen(
          repair: repair,
          settings: widget.settings,
          onUpdate: (updatedRepair) async {
            final index = repairs.indexWhere(
              (item) => item.id == updatedRepair.id,
            );

            if (index != -1) {
              setState(() {
                repairs[index] = updatedRepair;
              });

              await widget.onChanged(repairs);
            }
          },
          onDelete: (repairId) async {
            setState(() {
              repairs.removeWhere((item) => item.id == repairId);
            });

            await widget.onChanged(repairs);
          },
        ),
      ),
    );

    setState(() {});
  }

  Future<void> _deleteRepair(Repair repair) async {
    setState(() {
      repairs.removeWhere((item) => item.id == repair.id);
    });

    await widget.onChanged(repairs);
  }

  void _confirmDelete(Repair repair) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le dossier'),
          content: Text('Supprimer ${repair.id} ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteRepair(repair);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['Toutes', ...repairStatuses];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réparations'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: selectedFilter,
            decoration: const InputDecoration(labelText: 'Filtrer par statut'),
            items: filters
                .map(
                  (filter) => DropdownMenuItem(
                    value: filter,
                    child: Text(filter),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedFilter = value ?? 'Toutes';
              });
            },
          ),
          const SizedBox(height: 14),
          if (filteredRepairs.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aucun dossier dans cette catégorie.'),
              ),
            )
          else
            ...filteredRepairs.reversed.map(
              (repair) => Card(
                child: ListTile(
                  leading: const Icon(Icons.phone_android),
                  title: Text('${repair.brand} ${repair.model}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${repair.id} • ${repair.clientName}'),
                      Text(
                        '${repair.repairType} • '
                        '${repair.remaining.toStringAsFixed(2)} € restant',
                      ),
                      const SizedBox(height: 6),
                      StatusBadge(status: repair.status),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(repair),
                  ),
                  onTap: () => _openDetail(repair),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

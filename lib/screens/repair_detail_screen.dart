import 'package:flutter/material.dart';

import '../models/repair.dart';
import '../models/shop_settings.dart';
import '../services/pdf_service.dart';
import '../widgets/status_badge.dart';

class RepairDetailScreen extends StatefulWidget {
  final Repair repair;
  final ShopSettings settings;
  final Future<void> Function(Repair) onUpdate;
  final Future<void> Function(String) onDelete;

  const RepairDetailScreen({
    super.key,
    required this.repair,
    required this.settings,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<RepairDetailScreen> createState() => _RepairDetailScreenState();
}

class _RepairDetailScreenState extends State<RepairDetailScreen> {
  late Repair repair;
  bool pdfLoading = false;

  @override
  void initState() {
    super.initState();
    repair = widget.repair;
  }

  Future<void> _changeStatus(String status) async {
    final updated = repair.copyWith(status: status);

    setState(() {
      repair = updated;
    });

    await widget.onUpdate(updated);
  }

  Future<void> _generatePdf() async {
    setState(() {
      pdfLoading = true;
    });

    try {
      await PdfService.shareRepairPdf(
        repair: repair,
        settings: widget.settings,
      );
    } finally {
      if (mounted) {
        setState(() {
          pdfLoading = false;
        });
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le dossier'),
          content: Text('Voulez-vous supprimer ${repair.id} ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await widget.onDelete(repair.id);

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  Widget _info(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(value.isEmpty ? '-' : value),
      ),
    );
  }

  Widget _title(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(repair.id),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${repair.brand} ${repair.model}',
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StatusBadge(status: repair.status),
                  const SizedBox(height: 12),
                  Text(
                    '${repair.clientName} • ${repair.clientPhone}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: repair.status,
            decoration: const InputDecoration(labelText: 'Changer le statut'),
            items: repairStatuses
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                _changeStatus(value);
              }
            },
          ),
          _title('Client'),
          _info('Nom client', repair.clientName),
          _info('Téléphone client', repair.clientPhone),
          _title('Appareil'),
          _info('Marque', repair.brand),
          _info('Modèle', repair.model),
          _info('IMEI', repair.imei),
          _info('État à l’arrivée', repair.deviceState),
          _info('Accessoires déposés', repair.accessories),
          _title('Réparation'),
          _info('Problème constaté', repair.problem),
          _info('Réparation prévue', repair.repairType),
          _info('Garantie', repair.warranty),
          _info('Date de dépôt', repair.depositDate),
          _info('Date prévue de restitution', repair.returnDate),
          _title('Paiement'),
          _info('Prix total', '${repair.totalPrice.toStringAsFixed(2)} €'),
          _info('Acompte', '${repair.deposit.toStringAsFixed(2)} €'),
          _info('Reste à payer', '${repair.remaining.toStringAsFixed(2)} €'),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: pdfLoading ? null : _generatePdf,
            icon: pdfLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf),
            label: const Text('Générer le PDF'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Supprimer le dossier'),
          ),
        ],
      ),
    );
  }
}

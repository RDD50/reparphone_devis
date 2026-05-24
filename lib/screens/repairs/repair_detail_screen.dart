import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../models/app_data.dart';
import '../../models/payment_info.dart';
import '../../models/repair.dart';
import '../../services/pdf_service.dart';
import '../../widgets/status_badge.dart';
import 'repair_form_screen.dart';

class RepairDetailScreen extends StatefulWidget {
  final AppData data;
  final Repair repair;
  final Future<void> Function(AppData) onDataChanged;

  const RepairDetailScreen({
    super.key,
    required this.data,
    required this.repair,
    required this.onDataChanged,
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

  Future<void> _saveRepair(Repair updatedRepair) async {
    final repairs = widget.data.repairs.map((item) {
      return item.id == updatedRepair.id ? updatedRepair : item;
    }).toList();

    setState(() {
      repair = updatedRepair;
    });

    await widget.onDataChanged(widget.data.copyWith(repairs: repairs));
  }

  Future<void> _editRepair() async {
    final Repair? updatedRepair = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepairFormScreen(
          data: widget.data,
          nextId: repair.id,
          existingRepair: repair,
        ),
      ),
    );

    if (updatedRepair == null) return;

    await _saveRepair(updatedRepair);
  }

  Future<void> _changeRepairStatus(String status) async {
    await _saveRepair(repair.copyWith(status: status));
  }

  Future<void> _changePaymentStatus(String status) async {
    final paymentDate = status == 'Payé'
        ? Formatters.date(DateTime.now())
        : repair.paymentInfo.paymentDate;

    final updatedPayment = repair.paymentInfo.copyWith(
      status: status,
      paymentDate: paymentDate,
    );

    await _saveRepair(repair.copyWith(paymentInfo: updatedPayment));
  }

  Future<void> _changePaymentMethod(String method) async {
    final updatedPayment = repair.paymentInfo.copyWith(method: method);

    await _saveRepair(repair.copyWith(paymentInfo: updatedPayment));
  }

  Future<void> _sharePdf() async {
    setState(() => pdfLoading = true);

    try {
      await PdfService.shareRepairPdf(
        repair: repair,
        profile: widget.data.shopProfile,
      );
    } finally {
      if (mounted) {
        setState(() => pdfLoading = false);
      }
    }
  }

  Future<void> _savePdf() async {
    setState(() => pdfLoading = true);

    try {
      final file = await PdfService.saveRepairPdf(
        repair: repair,
        profile: widget.data.shopProfile,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF enregistré : ${file.path}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => pdfLoading = false);
      }
    }
  }

  Future<void> _deleteRepair() async {
    final repairs = widget.data.repairs
        .where((item) => item.id != repair.id)
        .toList();

    final events = widget.data.events
        .where((event) => event.repairId != repair.id)
        .toList();

    await widget.onDataChanged(
      widget.data.copyWith(
        repairs: repairs,
        events: events,
      ),
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le dossier'),
          content: Text('Supprimer définitivement ${repair.id} ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteRepair();
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

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _quickDropdown({
    required String label,
    required String value,
    required List<String> values,
    required void Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: values
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final linkedEvents = widget.data.events
        .where((event) => event.repairId == repair.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(repair.id),
        actions: [
          IconButton(
            onPressed: _editRepair,
            icon: const Icon(Icons.edit),
          ),
        ],
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
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusBadge(label: repair.status),
                      StatusBadge(label: repair.paymentInfo.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('${repair.clientName} • ${repair.clientPhone}'),
                ],
              ),
            ),
          ),

          _section('Actions rapides'),
          _quickDropdown(
            label: 'Statut dossier',
            value: repair.status,
            values: repairStatuses,
            onChanged: _changeRepairStatus,
          ),
          _quickDropdown(
            label: 'Statut paiement',
            value: repair.paymentInfo.status,
            values: paymentStatuses,
            onChanged: _changePaymentStatus,
          ),
          _quickDropdown(
            label: 'Mode de paiement',
            value: repair.paymentInfo.method,
            values: paymentMethods,
            onChanged: _changePaymentMethod,
          ),

          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _editRepair,
            icon: const Icon(Icons.edit),
            label: const Text('Modifier tout le dossier'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: pdfLoading ? null : _sharePdf,
            icon: const Icon(Icons.share),
            label: const Text('Partager PDF'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: pdfLoading ? null : _savePdf,
            icon: const Icon(Icons.save_alt),
            label: const Text('Enregistrer PDF'),
          ),

          _section('Client'),
          _info('Nom client', repair.clientName),
          _info('Téléphone client', repair.clientPhone),

          _section('Appareil'),
          _info('Marque', repair.brand),
          _info('Modèle', repair.model),
          _info('IMEI', repair.imei),
          _info('État à l’arrivée', repair.deviceState),
          _info('Accessoires déposés', repair.accessories),

          _section('Réparation'),
          _info('Type', repair.repairType),
          _info('Problème constaté', repair.problem),
          _info('Garantie', repair.warranty),
          _info('Date de dépôt', repair.depositDate),
          _info('Date prévue de restitution', repair.returnDate),

          _section('Paiement'),
          _info('Prix total', Formatters.money(repair.totalPrice)),
          _info('Acompte', Formatters.money(repair.deposit)),
          _info('Reste à payer', Formatters.money(repair.remaining)),
          _info('Statut paiement', repair.paymentInfo.status),
          _info('Mode paiement', repair.paymentInfo.method),
          _info('Date paiement', repair.paymentInfo.paymentDate),

          _section('Agenda lié'),
          if (linkedEvents.isEmpty)
            const Card(
              child: ListTile(
                title: Text('Aucun événement lié à ce dossier.'),
              ),
            )
          else
            ...linkedEvents.map(
              (event) => Card(
                child: ListTile(
                  leading: Icon(
                    event.isDone
                        ? Icons.check_circle
                        : Icons.event_note_outlined,
                  ),
                  title: Text(event.title),
                  subtitle: Text('${event.date} • ${event.type}'),
                  trailing: Text(event.time),
                ),
              ),
            ),

          const SizedBox(height: 14),
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

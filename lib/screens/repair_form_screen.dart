import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/repair.dart';

class RepairFormScreen extends StatefulWidget {
  final String nextId;

  const RepairFormScreen({
    super.key,
    required this.nextId,
  });

  @override
  State<RepairFormScreen> createState() => _RepairFormScreenState();
}

class _RepairFormScreenState extends State<RepairFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final clientNameController = TextEditingController();
  final clientPhoneController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final imeiController = TextEditingController();
  final deviceStateController = TextEditingController();
  final accessoriesController = TextEditingController();
  final problemController = TextEditingController();
  final priceController = TextEditingController();
  final depositController = TextEditingController();
  final warrantyController = TextEditingController(text: '3 mois');

  String selectedRepairType = repairTypes.first;
  String selectedStatus = repairStatuses.first;

  late DateTime depositDate;
  late DateTime returnDate;

  @override
  void initState() {
    super.initState();
    depositDate = DateTime.now();
    returnDate = DateTime.now().add(const Duration(days: 2));
  }

  @override
  void dispose() {
    clientNameController.dispose();
    clientPhoneController.dispose();
    brandController.dispose();
    modelController.dispose();
    imeiController.dispose();
    deviceStateController.dispose();
    accessoriesController.dispose();
    problemController.dispose();
    priceController.dispose();
    depositController.dispose();
    warrantyController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  double _parseAmount(String value) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0;
  }

  Future<void> _pickDepositDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: depositDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        depositDate = picked;
      });
    }
  }

  Future<void> _pickReturnDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: returnDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        returnDate = picked;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final repair = Repair(
      id: widget.nextId,
      clientName: clientNameController.text.trim(),
      clientPhone: clientPhoneController.text.trim(),
      brand: brandController.text.trim(),
      model: modelController.text.trim(),
      imei: imeiController.text.trim(),
      deviceState: deviceStateController.text.trim(),
      accessories: accessoriesController.text.trim(),
      problem: problemController.text.trim(),
      repairType: selectedRepairType,
      totalPrice: _parseAmount(priceController.text),
      deposit: _parseAmount(depositController.text),
      warranty: warrantyController.text.trim(),
      status: selectedStatus,
      depositDate: _formatDate(depositDate),
      returnDate: _formatDate(returnDate),
      createdAt: DateTime.now().toIso8601String(),
    );

    Navigator.pop(context, repair);
  }

  @override
  Widget build(BuildContext context) {
    final total = _parseAmount(priceController.text);
    final deposit = _parseAmount(depositController.text);
    final remaining = total - deposit;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau dossier ${widget.nextId}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('Client'),
            TextFormField(
              controller: clientNameController,
              decoration: const InputDecoration(labelText: 'Nom client'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nom client obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: clientPhoneController,
              decoration: const InputDecoration(labelText: 'Téléphone client'),
              keyboardType: TextInputType.phone,
            ),
            _section('Appareil'),
            TextFormField(
              controller: brandController,
              decoration: const InputDecoration(labelText: 'Marque'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Marque obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: modelController,
              decoration: const InputDecoration(labelText: 'Modèle'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Modèle obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: imeiController,
              decoration: const InputDecoration(labelText: 'IMEI facultatif'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: deviceStateController,
              decoration: const InputDecoration(
                labelText: 'État à l’arrivée',
                hintText: 'Ex: écran cassé, rayures, ne s’allume pas',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: accessoriesController,
              decoration: const InputDecoration(
                labelText: 'Accessoires déposés',
                hintText: 'Ex: chargeur, coque, carte SIM',
              ),
            ),
            _section('Réparation'),
            TextFormField(
              controller: problemController,
              decoration: const InputDecoration(labelText: 'Problème constaté'),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedRepairType,
              decoration: const InputDecoration(labelText: 'Type de réparation'),
              items: repairTypes
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedRepairType = value ?? selectedRepairType;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(labelText: 'Statut'),
              items: repairStatuses
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value ?? selectedStatus;
                });
              },
            ),
            _section('Prix'),
            TextFormField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Prix total'),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: depositController,
              decoration: const InputDecoration(labelText: 'Acompte'),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: const Text('Reste à payer'),
                trailing: Text(
                  '${remaining.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _section('Dates et garantie'),
            TextFormField(
              controller: warrantyController,
              decoration: const InputDecoration(labelText: 'Garantie'),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date de dépôt'),
              subtitle: Text(_formatDate(depositDate)),
              trailing: const Icon(Icons.calendar_month),
              onTap: _pickDepositDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date prévue de restitution'),
              subtitle: Text(_formatDate(returnDate)),
              trailing: const Icon(Icons.calendar_month),
              onTap: _pickReturnDate,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer la réparation'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../models/app_data.dart';
import '../../models/client.dart';
import '../../models/payment_info.dart';
import '../../models/repair.dart';

class RepairFormScreen extends StatefulWidget {
  final AppData data;
  final String nextId;
  final Repair? existingRepair;

  const RepairFormScreen({
    super.key,
    required this.data,
    required this.nextId,
    this.existingRepair,
  });

  @override
  State<RepairFormScreen> createState() => _RepairFormScreenState();
}

class _RepairFormScreenState extends State<RepairFormScreen> {
  final formKey = GlobalKey<FormState>();

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
  final warrantyController = TextEditingController();

  String clientId = '';
  String repairType = repairTypes.first;
  String status = repairStatuses.first;
  String paymentStatus = paymentStatuses.first;
  String paymentMethod = paymentMethods.first;

  DateTime depositDate = DateTime.now();
  DateTime returnDate = DateTime.now().add(const Duration(days: 2));
  DateTime? paymentDate;

  bool get isEditing => widget.existingRepair != null;

  @override
  void initState() {
    super.initState();

    final repair = widget.existingRepair;
    if (repair != null) {
      clientId = repair.clientId;
      clientNameController.text = repair.clientName;
      clientPhoneController.text = repair.clientPhone;
      brandController.text = repair.brand;
      modelController.text = repair.model;
      imeiController.text = repair.imei;
      deviceStateController.text = repair.deviceState;
      accessoriesController.text = repair.accessories;
      problemController.text = repair.problem;
      priceController.text = repair.totalPrice.toStringAsFixed(2);
      depositController.text = repair.deposit.toStringAsFixed(2);
      warrantyController.text = repair.warranty;
      repairType = repair.repairType;
      status = repair.status;
      paymentStatus = repair.paymentInfo.status;
      paymentMethod = repair.paymentInfo.method;
      depositDate = _parseDate(repair.depositDate) ?? DateTime.now();
      returnDate = _parseDate(repair.returnDate) ?? DateTime.now();
      paymentDate = _parseDate(repair.paymentInfo.paymentDate);
    } else {
      warrantyController.text = '3 mois';
    }
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

  DateTime? _parseDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;

    return DateTime(year, month, day);
  }

  Future<void> _pickDate({
    required DateTime initial,
    required void Function(DateTime) onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        onPicked(picked);
      });
    }
  }

  void _selectClient(Client client) {
    setState(() {
      clientId = client.id;
      clientNameController.text = client.name;
      clientPhoneController.text = client.phone;
    });
  }

  void _openClientPicker() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final clients = widget.data.clients;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Choisir un client',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (clients.isEmpty)
              const Text('Aucun client enregistré.')
            else
              ...clients.map(
                (client) => ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(client.name),
                  subtitle: Text(client.phone),
                  onTap: () {
                    Navigator.pop(context);
                    _selectClient(client);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  void _save() {
    if (!formKey.currentState!.validate()) return;

    final deposit = Formatters.parseAmount(depositController.text);
    final total = Formatters.parseAmount(priceController.text);

    final payment = PaymentInfo(
      status: paymentStatus,
      method: paymentMethod,
      paymentDate: paymentDate == null ? '' : Formatters.date(paymentDate!),
    );

    final repair = Repair(
      id: widget.existingRepair?.id ?? widget.nextId,
      clientId: clientId,
      clientName: clientNameController.text.trim(),
      clientPhone: clientPhoneController.text.trim(),
      brand: brandController.text.trim(),
      model: modelController.text.trim(),
      imei: imeiController.text.trim(),
      deviceState: deviceStateController.text.trim(),
      accessories: accessoriesController.text.trim(),
      problem: problemController.text.trim(),
      repairType: repairType,
      totalPrice: total,
      deposit: deposit,
      warranty: warrantyController.text.trim(),
      status: status,
      depositDate: Formatters.date(depositDate),
      returnDate: Formatters.date(returnDate),
      createdAt: widget.existingRepair?.createdAt ?? DateTime.now().toIso8601String(),
      paymentInfo: payment,
    );

    Navigator.pop(context, repair);
  }

  @override
  Widget build(BuildContext context) {
    final total = Formatters.parseAmount(priceController.text);
    final deposit = Formatters.parseAmount(depositController.text);
    final remaining = total - deposit;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier dossier' : 'Nouveau dossier ${widget.nextId}'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('Client'),
            OutlinedButton.icon(
              onPressed: _openClientPicker,
              icon: const Icon(Icons.search),
              label: const Text('Rechercher un client existant'),
            ),
            const SizedBox(height: 10),
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
              decoration: const InputDecoration(labelText: 'État à l’arrivée'),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: accessoriesController,
              decoration: const InputDecoration(labelText: 'Accessoires déposés'),
            ),
            _section('Réparation'),
            TextFormField(
              controller: problemController,
              decoration: const InputDecoration(labelText: 'Problème constaté'),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: repairType,
              decoration: const InputDecoration(labelText: 'Type de réparation'),
              items: repairTypes
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) => setState(() => repairType = value ?? repairType),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(labelText: 'Statut dossier'),
              items: repairStatuses
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) => setState(() => status = value ?? status),
            ),
            _section('Paiement'),
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
                  Formatters.money(remaining),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: paymentStatus,
              decoration: const InputDecoration(labelText: 'Statut paiement'),
              items: paymentStatuses
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) => setState(() => paymentStatus = value ?? paymentStatus),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: paymentMethod,
              decoration: const InputDecoration(labelText: 'Mode de paiement'),
              items: paymentMethods
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) => setState(() => paymentMethod = value ?? paymentMethod),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date de paiement'),
              subtitle: Text(paymentDate == null ? 'Non renseignée' : Formatters.date(paymentDate!)),
              trailing: const Icon(Icons.calendar_month),
              onTap: () => _pickDate(
                initial: paymentDate ?? DateTime.now(),
                onPicked: (date) => paymentDate = date,
              ),
            ),
            _section('Dates'),
            TextFormField(
              controller: warrantyController,
              decoration: const InputDecoration(labelText: 'Garantie'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date de dépôt'),
              subtitle: Text(Formatters.date(depositDate)),
              trailing: const Icon(Icons.calendar_month),
              onTap: () => _pickDate(
                initial: depositDate,
                onPicked: (date) => depositDate = date,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date de restitution prévue'),
              subtitle: Text(Formatters.date(returnDate)),
              trailing: const Icon(Icons.calendar_month),
              onTap: () => _pickDate(
                initial: returnDate,
                onPicked: (date) => returnDate = date,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(isEditing ? 'Enregistrer les modifications' : 'Créer le dossier'),
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
        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
      ),
    );
  }
}

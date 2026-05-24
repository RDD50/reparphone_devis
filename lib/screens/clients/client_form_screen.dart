import 'package:flutter/material.dart';

import '../../models/client.dart';

class ClientFormScreen extends StatefulWidget {
  final String nextId;
  final Client? existingClient;

  const ClientFormScreen({
    super.key,
    required this.nextId,
    this.existingClient,
  });

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final notesController = TextEditingController();

  bool get isEditing => widget.existingClient != null;

  @override
  void initState() {
    super.initState();

    final client = widget.existingClient;
    if (client != null) {
      nameController.text = client.name;
      phoneController.text = client.phone;
      emailController.text = client.email;
      addressController.text = client.address;
      notesController.text = client.notes;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!formKey.currentState!.validate()) return;

    final client = Client(
      id: widget.existingClient?.id ?? widget.nextId,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      address: addressController.text.trim(),
      notes: notesController.text.trim(),
      createdAt: widget.existingClient?.createdAt ?? DateTime.now().toIso8601String(),
    );

    Navigator.pop(context, client);
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label obligatoire';
                }
                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier client' : 'Nouveau client'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(nameController, 'Nom client', required: true),
            _field(
              phoneController,
              'Téléphone',
              keyboardType: TextInputType.phone,
            ),
            _field(
              emailController,
              'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            _field(
              addressController,
              'Adresse',
              maxLines: 2,
            ),
            _field(
              notesController,
              'Notes',
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(isEditing ? 'Enregistrer les modifications' : 'Créer le client'),
            ),
          ],
        ),
      ),
    );
  }
}

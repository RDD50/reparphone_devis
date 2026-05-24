import 'package:flutter/material.dart';

import '../models/shop_settings.dart';

class SettingsScreen extends StatefulWidget {
  final ShopSettings settings;

  const SettingsScreen({
    super.key,
    required this.settings,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final shopNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final siretController = TextEditingController();
  final warrantyTextController = TextEditingController();
  final termsTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    shopNameController.text = widget.settings.shopName;
    ownerNameController.text = widget.settings.ownerName;
    phoneController.text = widget.settings.phone;
    emailController.text = widget.settings.email;
    addressController.text = widget.settings.address;
    siretController.text = widget.settings.siret;
    warrantyTextController.text = widget.settings.warrantyText;
    termsTextController.text = widget.settings.termsText;
  }

  @override
  void dispose() {
    shopNameController.dispose();
    ownerNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    siretController.dispose();
    warrantyTextController.dispose();
    termsTextController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = ShopSettings(
      shopName: shopNameController.text.trim(),
      ownerName: ownerNameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      address: addressController.text.trim(),
      siret: siretController.text.trim(),
      warrantyText: warrantyTextController.text.trim(),
      termsText: termsTextController.text.trim(),
    );

    Navigator.pop(context, updated);
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres boutique'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(shopNameController, 'Nom boutique'),
          _field(ownerNameController, 'Nom responsable'),
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
          _field(siretController, 'SIRET'),
          _field(
            warrantyTextController,
            'Mention garantie',
            maxLines: 3,
          ),
          _field(
            termsTextController,
            'Conditions générales',
            maxLines: 5,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Enregistrer les paramètres'),
          ),
        ],
      ),
    );
  }
}

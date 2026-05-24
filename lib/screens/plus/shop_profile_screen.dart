import 'package:flutter/material.dart';

import '../../models/app_data.dart';
import '../../models/shop_profile.dart';

class ShopProfileScreen extends StatefulWidget {
  final AppData data;
  final Future<void> Function(AppData) onDataChanged;

  const ShopProfileScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  final appDisplayNameController = TextEditingController();
  final shopNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final siretController = TextEditingController();
  final primaryColorHexController = TextEditingController();
  final warrantyTextController = TextEditingController();
  final termsTextController = TextEditingController();
  final commercialTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final profile = widget.data.shopProfile;

    appDisplayNameController.text = profile.appDisplayName;
    shopNameController.text = profile.shopName;
    ownerNameController.text = profile.ownerName;
    phoneController.text = profile.phone;
    emailController.text = profile.email;
    addressController.text = profile.address;
    siretController.text = profile.siret;
    primaryColorHexController.text = profile.primaryColorHex;
    warrantyTextController.text = profile.warrantyText;
    termsTextController.text = profile.termsText;
    commercialTextController.text = profile.commercialText;
  }

  @override
  void dispose() {
    appDisplayNameController.dispose();
    shopNameController.dispose();
    ownerNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    siretController.dispose();
    primaryColorHexController.dispose();
    warrantyTextController.dispose();
    termsTextController.dispose();
    commercialTextController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final profile = ShopProfile(
      appDisplayName: appDisplayNameController.text.trim(),
      shopName: shopNameController.text.trim(),
      ownerName: ownerNameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      address: addressController.text.trim(),
      siret: siretController.text.trim(),
      primaryColorHex: primaryColorHexController.text.trim(),
      warrantyText: warrantyTextController.text.trim(),
      termsText: termsTextController.text.trim(),
      commercialText: commercialTextController.text.trim(),
    );

    await widget.onDataChanged(
      widget.data.copyWith(shopProfile: profile),
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compte boutique'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(appDisplayNameController, 'Nom commercial de l’application'),
          _field(shopNameController, 'Nom boutique'),
          _field(ownerNameController, 'Responsable'),
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
          _field(addressController, 'Adresse', maxLines: 2),
          _field(siretController, 'SIRET'),
          _field(primaryColorHexController, 'Couleur principale HEX'),
          _field(commercialTextController, 'Texte commercial', maxLines: 3),
          _field(warrantyTextController, 'Mention garantie', maxLines: 3),
          _field(termsTextController, 'Conditions générales PDF', maxLines: 5),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

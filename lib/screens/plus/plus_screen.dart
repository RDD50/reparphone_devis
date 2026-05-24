import 'package:flutter/material.dart';

import '../../models/app_data.dart';
import '../../widgets/quick_action_button.dart';
import 'about_screen.dart';
import 'backup_screen.dart';
import 'finance_screen.dart';
import 'shop_profile_screen.dart';

class PlusScreen extends StatelessWidget {
  final AppData data;
  final Future<void> Function(AppData) onDataChanged;

  const PlusScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  void _open(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plus'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          QuickActionButton(
            label: 'Finances',
            icon: Icons.payments_outlined,
            onTap: () => _open(
              context,
              FinanceScreen(
                data: data,
                onDataChanged: onDataChanged,
              ),
            ),
          ),
          QuickActionButton(
            label: 'Sauvegarde',
            icon: Icons.backup_outlined,
            onTap: () => _open(
              context,
              BackupScreen(
                data: data,
                onDataChanged: onDataChanged,
              ),
            ),
          ),
          QuickActionButton(
            label: 'Compte boutique',
            icon: Icons.store_outlined,
            onTap: () => _open(
              context,
              ShopProfileScreen(
                data: data,
                onDataChanged: onDataChanged,
              ),
            ),
          ),
          QuickActionButton(
            label: 'À propos',
            icon: Icons.info_outline,
            onTap: () => _open(
              context,
              AboutScreen(data: data),
            ),
          ),
        ],
      ),
    );
  }
}

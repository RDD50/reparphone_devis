import 'package:flutter/material.dart';

import '../models/repair.dart';
import '../models/shop_settings.dart';
import '../services/storage_service.dart';
import '../widgets/dashboard_card.dart';
import 'repair_form_screen.dart';
import 'repair_list_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Repair> repairs = [];
  ShopSettings settings = ShopSettings.defaultSettings();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final loadedRepairs = await StorageService.loadRepairs();
    final loadedSettings = await StorageService.loadSettings();

    setState(() {
      repairs = loadedRepairs;
      settings = loadedSettings;
      loading = false;
    });
  }

  Future<void> _saveRepairs() async {
    await StorageService.saveRepairs(repairs);
  }

  Future<void> _openNewRepair() async {
    final nextId = StorageService.nextRepairId(repairs);

    final Repair? repair = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepairFormScreen(nextId: nextId),
      ),
    );

    if (repair != null) {
      setState(() {
        repairs.add(repair);
      });

      await _saveRepairs();
    }
  }

  Future<void> _openRepairs() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepairListScreen(
          repairs: repairs,
          settings: settings,
          onChanged: (updatedRepairs) async {
            setState(() {
              repairs = updatedRepairs;
            });

            await _saveRepairs();
          },
        ),
      ),
    );

    await _loadAll();
  }

  Future<void> _openSettings() async {
    final ShopSettings? updatedSettings = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(settings: settings),
      ),
    );

    if (updatedSettings != null) {
      setState(() {
        settings = updatedSettings;
      });

      await StorageService.saveSettings(updatedSettings);
    }
  }

  int get activeCount {
    return repairs.where((repair) => repair.isActive).length;
  }

  int get finishedCount {
    return repairs.where((repair) => repair.isFinished).length;
  }

  double get totalDeposits {
    return repairs.fold(0, (sum, repair) => sum + repair.deposit);
  }

  double get totalRemaining {
    return repairs.fold(0, (sum, repair) => sum + repair.remaining);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ReparPhone Devis V2'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            settings.shopName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gestion des dépôts, devis et réparations téléphone',
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.25,
            children: [
              DashboardCard(
                title: 'En cours',
                value: activeCount.toString(),
                icon: Icons.build_circle_outlined,
              ),
              DashboardCard(
                title: 'Terminées',
                value: finishedCount.toString(),
                icon: Icons.check_circle_outline,
              ),
              DashboardCard(
                title: 'Acomptes',
                value: '${totalDeposits.toStringAsFixed(2)} €',
                icon: Icons.payments_outlined,
              ),
              DashboardCard(
                title: 'Restant dû',
                value: '${totalRemaining.toStringAsFixed(2)} €',
                icon: Icons.receipt_long_outlined,
              ),
            ],
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: _openNewRepair,
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle réparation'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _openRepairs,
            icon: const Icon(Icons.list_alt),
            label: const Text('Liste des réparations'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _openSettings,
            icon: const Icon(Icons.store),
            label: const Text('Paramètres boutique'),
          ),
          const SizedBox(height: 22),
          const Text(
            'Derniers dossiers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (repairs.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aucune réparation enregistrée.'),
              ),
            )
          else
            ...repairs.reversed.take(5).map(
                  (repair) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.phone_android),
                      title: Text('${repair.brand} ${repair.model}'),
                      subtitle: Text('${repair.id} • ${repair.clientName}'),
                      trailing: Text(
                        '${repair.remaining.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

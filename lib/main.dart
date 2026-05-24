import 'package:flutter/material.dart';

void main() {
  runApp(const ReparPhoneApp());
}

class ReparPhoneApp extends StatelessWidget {
  const ReparPhoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReparPhone Devis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Repair {
  final String clientName;
  final String clientPhone;
  final String brand;
  final String model;
  final String problem;
  final String repairType;
  final double totalPrice;
  final double deposit;
  final String status;

  Repair({
    required this.clientName,
    required this.clientPhone,
    required this.brand,
    required this.model,
    required this.problem,
    required this.repairType,
    required this.totalPrice,
    required this.deposit,
    required this.status,
  });

  double get remaining => totalPrice - deposit;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Repair> repairs = [];

  void _openNewRepairPage() async {
    final Repair? newRepair = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NewRepairPage(),
      ),
    );

    if (newRepair != null) {
      setState(() {
        repairs.add(newRepair);
      });
    }
  }

  int get pendingCount {
    return repairs.where((repair) => repair.status != 'Livré').length;
  }

  double get totalDeposits {
    return repairs.fold(0, (sum, repair) => sum + repair.deposit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReparPhone Devis'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tableau de bord',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'En cours',
                  value: pendingCount.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardCard(
                  title: 'Acomptes',
                  value: '${totalDeposits.toStringAsFixed(2)} €',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _openNewRepairPage,
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle réparation'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Réparations',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (repairs.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aucune réparation enregistrée pour le moment.'),
              ),
            )
          else
            ...repairs.map(
              (repair) => Card(
                child: ListTile(
                  title: Text('${repair.brand} ${repair.model}'),
                  subtitle: Text(
                    '${repair.clientName} • ${repair.repairType}\n'
                    'Prix: ${repair.totalPrice.toStringAsFixed(2)} € • '
                    'Reste: ${repair.remaining.toStringAsFixed(2)} €',
                  ),
                  isThreeLine: true,
                  trailing: Text(repair.status),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class NewRepairPage extends StatefulWidget {
  const NewRepairPage({super.key});

  @override
  State<NewRepairPage> createState() => _NewRepairPageState();
}

class _NewRepairPageState extends State<NewRepairPage> {
  final _formKey = GlobalKey<FormState>();

  final clientNameController = TextEditingController();
  final clientPhoneController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final problemController = TextEditingController();
  final priceController = TextEditingController();
  final depositController = TextEditingController();

  String repairType = 'Diagnostic';
  String status = 'En attente';

  final List<String> repairTypes = [
    'Diagnostic',
    'Remplacement écran',
    'Remplacement batterie',
    'Connecteur de charge',
    'Caméra',
    'Haut-parleur',
    'Micro',
    'Désoxydation',
    'Réinitialisation logiciel',
    'Sauvegarde données',
    'Autre réparation',
  ];

  final List<String> statuses = [
    'En attente',
    'En réparation',
    'En attente de pièce',
    'Terminé',
    'Livré',
    'Annulé',
  ];

  @override
  void dispose() {
    clientNameController.dispose();
    clientPhoneController.dispose();
    brandController.dispose();
    modelController.dispose();
    problemController.dispose();
    priceController.dispose();
    depositController.dispose();
    super.dispose();
  }

  void _saveRepair() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final totalPrice = double.tryParse(
          priceController.text.replaceAll(',', '.'),
        ) ??
        0;

    final deposit = double.tryParse(
          depositController.text.replaceAll(',', '.'),
        ) ??
        0;

    final repair = Repair(
      clientName: clientNameController.text.trim(),
      clientPhone: clientPhoneController.text.trim(),
      brand: brandController.text.trim(),
      model: modelController.text.trim(),
      problem: problemController.text.trim(),
      repairType: repairType,
      totalPrice: totalPrice,
      deposit: deposit,
      status: status,
    );

    Navigator.pop(context, repair);
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = double.tryParse(
          priceController.text.replaceAll(',', '.'),
        ) ??
        0;

    final deposit = double.tryParse(
          depositController.text.replaceAll(',', '.'),
        ) ??
        0;

    final remaining = totalPrice - deposit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle réparation'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Client',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: clientNameController,
              decoration: const InputDecoration(labelText: 'Nom du client'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nom du client obligatoire';
                }
                return null;
              },
            ),
            TextFormField(
              controller: clientPhoneController,
              decoration: const InputDecoration(labelText: 'Téléphone client'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            const Text(
              'Appareil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
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
            TextFormField(
              controller: problemController,
              decoration: const InputDecoration(labelText: 'Problème constaté'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            const Text(
              'Réparation',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              value: repairType,
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
                  repairType = value ?? repairType;
                });
              },
            ),
            TextFormField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Prix total'),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            TextFormField(
              controller: depositController,
              decoration: const InputDecoration(labelText: 'Acompte'),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Reste à payer'),
                trailing: Text(
                  '${remaining.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(labelText: 'Statut'),
              items: statuses
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  status = value ?? status;
                });
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saveRepair,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}

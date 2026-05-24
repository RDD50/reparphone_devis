import 'package:flutter/material.dart';

import '../../models/app_data.dart';
import '../../services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  final AppData data;
  final Future<void> Function(AppData) onDataChanged;

  const BackupScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final importController = TextEditingController();
  String exportedJson = '';

  @override
  void dispose() {
    importController.dispose();
    super.dispose();
  }

  void _generateExport() {
    setState(() {
      exportedJson = BackupService.exportToJson(widget.data);
    });
  }

  Future<void> _saveBackupFile() async {
    final file = await BackupService.saveBackupFile(widget.data);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sauvegarde enregistrée : ${file.path}')),
    );
  }

  Future<void> _importBackup() async {
    try {
      final importedData = BackupService.importFromJson(importController.text);
      await widget.onDataChanged(importedData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sauvegarde importée.')),
      );

      Navigator.pop(context);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sauvegarde invalide.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sauvegarde'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Exporter les données',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Génère une sauvegarde JSON contenant clients, dossiers, agenda et paramètres boutique.',
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _generateExport,
            icon: const Icon(Icons.code),
            label: const Text('Générer sauvegarde texte'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _saveBackupFile,
            icon: const Icon(Icons.save_alt),
            label: const Text('Enregistrer fichier de sauvegarde'),
          ),
          if (exportedJson.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: exportedJson),
              readOnly: true,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Sauvegarde JSON à copier',
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Importer une sauvegarde',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: importController,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Coller une sauvegarde JSON',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _importBackup,
            icon: const Icon(Icons.upload),
            label: const Text('Importer sauvegarde'),
          ),
        ],
      ),
    );
  }
}

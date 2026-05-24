import 'package:flutter/material.dart';

import '../../models/app_data.dart';
import '../../models/client.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/repair_list_item.dart';
import '../repairs/repair_detail_screen.dart';
import 'client_form_screen.dart';

class ClientDetailScreen extends StatefulWidget {
  final AppData data;
  final Client client;
  final Future<void> Function(AppData) onDataChanged;

  const ClientDetailScreen({
    super.key,
    required this.data,
    required this.client,
    required this.onDataChanged,
  });

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  late Client client;

  @override
  void initState() {
    super.initState();
    client = widget.client;
  }

  Future<void> _editClient() async {
    final Client? updatedClient = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientFormScreen(
          nextId: client.id,
          existingClient: client,
        ),
      ),
    );

    if (updatedClient == null) return;

    final clients = widget.data.clients.map((item) {
      return item.id == updatedClient.id ? updatedClient : item;
    }).toList();

    final repairs = widget.data.repairs.map((repair) {
      if (repair.clientId == updatedClient.id) {
        return repair.copyWith(
          clientName: updatedClient.name,
          clientPhone: updatedClient.phone,
        );
      }
      return repair;
    }).toList();

    setState(() {
      client = updatedClient;
    });

    await widget.onDataChanged(
      widget.data.copyWith(
        clients: clients,
        repairs: repairs,
      ),
    );
  }

  Future<void> _deleteClient() async {
    final hasRepairs = widget.data.repairs.any((repair) {
      return repair.clientId == client.id;
    });

    if (hasRepairs) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de supprimer un client avec des dossiers liés.'),
        ),
      );
      return;
    }

    final clients = widget.data.clients
        .where((item) => item.id != client.id)
        .toList();

    await widget.onDataChanged(widget.data.copyWith(clients: clients));

    if (mounted) Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le client'),
          content: Text('Supprimer ${client.name} ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteClient();
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

  @override
  Widget build(BuildContext context) {
    final clientRepairs = widget.data.repairs
        .where((repair) => repair.clientId == client.id)
        .toList()
        .reversed
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(client.name),
        actions: [
          IconButton(
            onPressed: _editClient,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(
                client.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text(client.phone.isEmpty ? 'Téléphone non renseigné' : client.phone),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _editClient,
            icon: const Icon(Icons.edit),
            label: const Text('Modifier client'),
          ),
          const SizedBox(height: 12),
          _info('Téléphone', client.phone),
          _info('Email', client.email),
          _info('Adresse', client.address),
          _info('Notes', client.notes),
          const SizedBox(height: 18),
          const Text(
            'Historique des dossiers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          if (clientRepairs.isEmpty)
            const EmptyStateCard(
              message: 'Aucun dossier lié à ce client.',
              icon: Icons.folder_open,
            )
          else
            ...clientRepairs.map(
              (repair) => RepairListItem(
                repair: repair,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RepairDetailScreen(
                        data: widget.data,
                        repair: repair,
                        onDataChanged: widget.onDataChanged,
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Supprimer client'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/app_data.dart';
import '../../models/client.dart';
import '../../services/storage_service.dart';
import '../../widgets/client_list_item.dart';
import '../../widgets/empty_state_card.dart';
import 'client_detail_screen.dart';
import 'client_form_screen.dart';

class ClientListScreen extends StatefulWidget {
  final AppData data;
  final Future<void> Function(AppData) onDataChanged;

  const ClientListScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  String query = '';

  List<Client> get filteredClients {
    var clients = widget.data.clients;

    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();

      clients = clients.where((client) {
        return client.name.toLowerCase().contains(q) ||
            client.phone.toLowerCase().contains(q) ||
            client.email.toLowerCase().contains(q);
      }).toList();
    }

    return clients.reversed.toList();
  }

  Future<void> _newClient() async {
    final nextId = StorageService.nextClientId(widget.data.clients);

    final Client? client = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientFormScreen(nextId: nextId),
      ),
    );

    if (client == null) return;

    await widget.onDataChanged(
      widget.data.copyWith(
        clients: [...widget.data.clients, client],
      ),
    );
  }

  Future<void> _openDetail(Client client) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientDetailScreen(
          data: widget.data,
          client: client,
          onDataChanged: widget.onDataChanged,
        ),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newClient,
        icon: const Icon(Icons.person_add),
        label: const Text('Client'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Rechercher un client',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
          ),
          const SizedBox(height: 14),
          if (filteredClients.isEmpty)
            const EmptyStateCard(
              message: 'Aucun client trouvé.',
              icon: Icons.people_outline,
            )
          else
            ...filteredClients.map(
              (client) => ClientListItem(
                client: client,
                onTap: () => _openDetail(client),
              ),
            ),
        ],
      ),
    );
  }
}

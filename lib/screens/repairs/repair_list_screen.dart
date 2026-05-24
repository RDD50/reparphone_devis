import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../models/app_data.dart';
import '../../models/calendar_event.dart';
import '../../models/client.dart';
import '../../models/repair.dart';
import '../../services/storage_service.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/repair_list_item.dart';
import 'repair_detail_screen.dart';
import 'repair_form_screen.dart';

class RepairListScreen extends StatefulWidget {
  final AppData data;
  final Future<void> Function(AppData) onDataChanged;

  const RepairListScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<RepairListScreen> createState() => _RepairListScreenState();
}

class _RepairListScreenState extends State<RepairListScreen> {
  String query = '';
  String filter = 'Tous';

  List<Repair> get filteredRepairs {
    var repairs = widget.data.repairs;

    if (filter != 'Tous') {
      repairs = repairs.where((repair) => repair.status == filter).toList();
    }

    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();

      repairs = repairs.where((repair) {
        return repair.id.toLowerCase().contains(q) ||
            repair.clientName.toLowerCase().contains(q) ||
            repair.clientPhone.toLowerCase().contains(q) ||
            repair.brand.toLowerCase().contains(q) ||
            repair.model.toLowerCase().contains(q);
      }).toList();
    }

    return repairs.reversed.toList();
  }

  Future<void> _openNewRepair() async {
    final nextId = StorageService.nextRepairId(widget.data.repairs);

    final Repair? repair = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepairFormScreen(
          data: widget.data,
          nextId: nextId,
        ),
      ),
    );

    if (repair == null) return;

    final clientId = repair.clientId.isEmpty
        ? StorageService.nextClientId(widget.data.clients)
        : repair.clientId;

    final clientExists = widget.data.clients.any((client) {
      return client.id == clientId;
    });

    final client = Client(
      id: clientId,
      name: repair.clientName,
      phone: repair.clientPhone,
      email: '',
      address: '',
      notes: '',
      createdAt: DateTime.now().toIso8601String(),
    );

    final updatedRepair = repair.copyWith(clientId: clientId);

    final depositEvent = CalendarEvent(
      id: StorageService.nextEventId(widget.data.events),
      repairId: updatedRepair.id,
      clientId: clientId,
      title: 'Prise en charge - ${updatedRepair.brand} ${updatedRepair.model}',
      description: updatedRepair.clientName,
      type: 'Prise en charge',
      date: updatedRepair.depositDate,
      time: '',
      isDone: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    final returnEvent = CalendarEvent(
      id: '${depositEvent.id}-return',
      repairId: updatedRepair.id,
      clientId: clientId,
      title: 'Restitution prévue - ${updatedRepair.brand} ${updatedRepair.model}',
      description: updatedRepair.clientName,
      type: 'Restitution prévue',
      date: updatedRepair.returnDate,
      time: '',
      isDone: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    await widget.onDataChanged(
      widget.data.copyWith(
        clients: [
          ...widget.data.clients,
          if (!clientExists) client,
        ],
        repairs: [...widget.data.repairs, updatedRepair],
        events: [...widget.data.events, depositEvent, returnEvent],
      ),
    );
  }

  Future<void> _openDetail(Repair repair) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepairDetailScreen(
          data: widget.data,
          repair: repair,
          onDataChanged: widget.onDataChanged,
        ),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['Tous', ...repairStatuses];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dossiers'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewRepair,
        icon: const Icon(Icons.add),
        label: const Text('Dossier'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Rechercher un dossier',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: filter,
            decoration: const InputDecoration(labelText: 'Filtrer par statut'),
            items: filters
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) {
              setState(() {
                filter = value ?? 'Tous';
              });
            },
          ),
          const SizedBox(height: 14),
          if (filteredRepairs.isEmpty)
            const EmptyStateCard(
              message: 'Aucun dossier trouvé.',
              icon: Icons.folder_open,
            )
          else
            ...filteredRepairs.map(
              (repair) => RepairListItem(
                repair: repair,
                onTap: () => _openDetail(repair),
              ),
            ),
        ],
      ),
    );
  }
}

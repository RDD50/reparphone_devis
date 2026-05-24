import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../models/app_data.dart';
import '../../models/calendar_event.dart';
import '../../models/client.dart';
import '../../models/payment_info.dart';
import '../../models/repair.dart';
import '../../services/storage_service.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/quick_action_button.dart';
import '../../widgets/repair_list_item.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../repairs/repair_form_screen.dart';

class DashboardScreen extends StatelessWidget {
  final AppData data;
  final Future<void> Function(AppData) onDataChanged;
  final void Function(int index) openTab;

  const DashboardScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
    required this.openTab,
  });

  int get activeRepairs {
    return data.repairs.where((repair) => repair.isActive).length;
  }

  int get finishedRepairs {
    return data.repairs.where((repair) => repair.isFinished).length;
  }

  double get paidTotal {
    return data.repairs
        .where((repair) => repair.paymentInfo.status == 'Payé')
        .fold(0, (sum, repair) => sum + repair.totalPrice);
  }

  double get remainingTotal {
    return data.repairs.fold(0, (sum, repair) => sum + repair.remaining);
  }

  List<CalendarEvent> get todayEvents {
    final today = Formatters.date(DateTime.now());

    final events = data.events.where((event) => event.date == today).toList();

    events.sort((a, b) => a.time.compareTo(b.time));
    return events;
  }

  Future<void> _newRepair(BuildContext context) async {
    final nextId = StorageService.nextRepairId(data.repairs);

    final Repair? repair = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepairFormScreen(
          data: data,
          nextId: nextId,
        ),
      ),
    );

    if (repair == null) {
      return;
    }

    final client = Client(
      id: repair.clientId.isEmpty
          ? StorageService.nextClientId(data.clients)
          : repair.clientId,
      name: repair.clientName,
      phone: repair.clientPhone,
      email: '',
      address: '',
      notes: '',
      createdAt: DateTime.now().toIso8601String(),
    );

    final clientExists = data.clients.any((item) => item.id == client.id);

    final clients = [
      ...data.clients,
      if (!clientExists) client,
    ];

    final depositEvent = CalendarEvent(
      id: StorageService.nextEventId(data.events),
      repairId: repair.id,
      clientId: client.id,
      title: 'Prise en charge - ${repair.brand} ${repair.model}',
      description: repair.clientName,
      type: 'Prise en charge',
      date: repair.depositDate,
      time: '',
      isDone: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    final returnEvent = CalendarEvent(
      id: '${depositEvent.id}-return',
      repairId: repair.id,
      clientId: client.id,
      title: 'Restitution prévue - ${repair.brand} ${repair.model}',
      description: repair.clientName,
      type: 'Restitution prévue',
      date: repair.returnDate,
      time: '',
      isDone: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    final updatedRepair = repair.copyWith(
      clientId: client.id,
      paymentInfo: repair.paymentInfo.status == 'Non payé' && repair.deposit > 0
          ? repair.paymentInfo.copyWith(status: 'Acompte versé')
          : repair.paymentInfo,
    );

    await onDataChanged(
      data.copyWith(
        clients: clients,
        repairs: [...data.repairs, updatedRepair],
        events: [...data.events, depositEvent, returnEvent],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latestRepairs = data.repairs.reversed.take(4).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(data.shopProfile.appDisplayName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            data.shopProfile.shopName,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.shopProfile.commercialText,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.23,
            children: [
              StatCard(
                title: 'En cours',
                value: activeRepairs.toString(),
                icon: Icons.construction,
              ),
              StatCard(
                title: 'Terminées',
                value: finishedRepairs.toString(),
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
              StatCard(
                title: 'Encaissé',
                value: Formatters.money(paidTotal),
                icon: Icons.payments_outlined,
                color: Colors.green,
              ),
              StatCard(
                title: 'Restant dû',
                value: Formatters.money(remainingTotal),
                icon: Icons.receipt_long_outlined,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _newRepair(context),
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle réparation'),
          ),
          SectionHeader(title: 'Actions rapides'),
          QuickActionButton(
            label: 'Voir les dossiers',
            icon: Icons.build_outlined,
            onTap: () => openTab(1),
          ),
          QuickActionButton(
            label: 'Carnet clients',
            icon: Icons.people_outline,
            onTap: () => openTab(2),
          ),
          QuickActionButton(
            label: 'Agenda mensuel',
            icon: Icons.calendar_month_outlined,
            onTap: () => openTab(3),
          ),
          SectionHeader(title: 'Aujourd’hui'),
          if (todayEvents.isEmpty)
            const EmptyStateCard(
              message: 'Aucun événement prévu aujourd’hui.',
              icon: Icons.event_available,
            )
          else
            ...todayEvents.map(
              (event) => Card(
                child: ListTile(
                  leading: Icon(
                    event.isDone
                        ? Icons.check_circle
                        : Icons.event_note_outlined,
                  ),
                  title: Text(event.title),
                  subtitle: Text(event.type),
                  trailing: Text(event.time),
                ),
              ),
            ),
          SectionHeader(
            title: 'Derniers dossiers',
            actionLabel: 'Tout voir',
            onAction: () => openTab(1),
          ),
          if (latestRepairs.isEmpty)
            const EmptyStateCard(
              message: 'Aucun dossier enregistré.',
              icon: Icons.folder_open,
            )
          else
            ...latestRepairs.map(
              (repair) => RepairListItem(
                repair: repair,
                onTap: () => openTab(1),
              ),
            ),
        ],
      ),
    );
  }
}

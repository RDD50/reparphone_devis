import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../models/app_data.dart';
import '../../models/calendar_event.dart';
import '../../models/repair.dart';
import '../../services/storage_service.dart';

class EventFormScreen extends StatefulWidget {
  final AppData data;
  final CalendarEvent? existingEvent;
  final DateTime initialDate;

  const EventFormScreen({
    super.key,
    required this.data,
    required this.initialDate,
    this.existingEvent,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final timeController = TextEditingController();

  String type = eventTypes.first;
  String repairId = '';
  String clientId = '';
  late DateTime date;
  bool isDone = false;

  bool get isEditing => widget.existingEvent != null;

  @override
  void initState() {
    super.initState();

    final event = widget.existingEvent;
    if (event != null) {
      titleController.text = event.title;
      descriptionController.text = event.description;
      timeController.text = event.time;
      type = event.type;
      repairId = event.repairId;
      clientId = event.clientId;
      date = _parseDate(event.date) ?? widget.initialDate;
      isDone = event.isDone;
    } else {
      date = widget.initialDate;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    timeController.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;

    return DateTime(year, month, day);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        date = picked;
      });
    }
  }

  void _selectRepair(Repair repair) {
    setState(() {
      repairId = repair.id;
      clientId = repair.clientId;

      if (titleController.text.trim().isEmpty) {
        titleController.text = '$type - ${repair.brand} ${repair.model}';
      }

      if (descriptionController.text.trim().isEmpty) {
        descriptionController.text = '${repair.id} • ${repair.clientName}';
      }
    });
  }

  void _openRepairPicker() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final repairs = widget.data.repairs.reversed.toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Lier à un dossier',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (repairs.isEmpty)
              const Text('Aucun dossier disponible.')
            else
              ...repairs.map(
                (repair) => ListTile(
                  leading: const Icon(Icons.build),
                  title: Text('${repair.brand} ${repair.model}'),
                  subtitle: Text('${repair.id} • ${repair.clientName}'),
                  onTap: () {
                    Navigator.pop(context);
                    _selectRepair(repair);
                  },
                ),
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.link_off),
              title: const Text('Événement non lié à un dossier'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  repairId = '';
                  clientId = '';
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _save() {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titre obligatoire.')),
      );
      return;
    }

    final event = CalendarEvent(
      id: widget.existingEvent?.id ?? StorageService.nextEventId(widget.data.events),
      repairId: repairId,
      clientId: clientId,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      type: type,
      date: Formatters.date(date),
      time: timeController.text.trim(),
      isDone: isDone,
      createdAt: widget.existingEvent?.createdAt ?? DateTime.now().toIso8601String(),
    );

    Navigator.pop(context, event);
  }

  @override
  Widget build(BuildContext context) {
    final selectedRepair = repairId.isEmpty
        ? null
        : widget.data.repairs.where((repair) => repair.id == repairId).cast<Repair?>().firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier événement' : 'Nouvel événement'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: type,
            decoration: const InputDecoration(labelText: 'Type événement'),
            items: eventTypes
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) {
              setState(() {
                type = value ?? type;
              });
            },
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _openRepairPicker,
            icon: const Icon(Icons.link),
            label: Text(
              selectedRepair == null
                  ? 'Lier à un dossier ou laisser libre'
                  : 'Lié à ${selectedRepair.id}',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Titre'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: timeController,
            decoration: const InputDecoration(
              labelText: 'Heure facultative',
              hintText: 'Ex: 14:30',
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(Formatters.date(date)),
            trailing: const Icon(Icons.calendar_month),
            onTap: _pickDate,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Événement fait'),
            value: isDone,
            onChanged: (value) {
              setState(() {
                isDone = value;
              });
            },
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: Text(isEditing ? 'Enregistrer les modifications' : 'Créer événement'),
          ),
        ],
      ),
    );
  }
}

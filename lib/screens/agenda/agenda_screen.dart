import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../models/app_data.dart';
import '../../models/calendar_event.dart';
import '../../models/repair.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/status_badge.dart';
import '../repairs/repair_detail_screen.dart';
import 'event_form_screen.dart';

class AgendaScreen extends StatefulWidget {
  final AppData data;
  final Future<void> Function(AppData) onDataChanged;

  const AgendaScreen({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime selectedDay = DateTime.now();

  String _dateKey(DateTime date) {
    return Formatters.date(date);
  }

  List<CalendarEvent> eventsForDay(DateTime day) {
    final key = _dateKey(day);

    final events = widget.data.events.where((event) => event.date == key).toList();

    events.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.time.compareTo(b.time);
    });

    return events;
  }

  List<DateTime?> monthCells() {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final lastDay = DateTime(visibleMonth.year, visibleMonth.month + 1, 0);
    final startOffset = firstDay.weekday - 1;

    final cells = <DateTime?>[];

    for (int i = 0; i < startOffset; i++) {
      cells.add(null);
    }

    for (int day = 1; day <= lastDay.day; day++) {
      cells.add(DateTime(visibleMonth.year, visibleMonth.month, day));
    }

    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return cells;
  }

  String monthLabel(DateTime date) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  void previousMonth() {
    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month - 1);
    });
  }

  void nextMonth() {
    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + 1);
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _newEvent({DateTime? date}) async {
    final CalendarEvent? event = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventFormScreen(
          data: widget.data,
          initialDate: date ?? selectedDay,
        ),
      ),
    );

    if (event == null) return;

    await widget.onDataChanged(
      widget.data.copyWith(
        events: [...widget.data.events, event],
      ),
    );

    setState(() {});
  }

  Future<void> _editEvent(CalendarEvent event) async {
    final CalendarEvent? updatedEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventFormScreen(
          data: widget.data,
          initialDate: selectedDay,
          existingEvent: event,
        ),
      ),
    );

    if (updatedEvent == null) return;

    final events = widget.data.events.map((item) {
      return item.id == updatedEvent.id ? updatedEvent : item;
    }).toList();

    await widget.onDataChanged(widget.data.copyWith(events: events));

    setState(() {});
  }

  Future<void> _toggleDone(CalendarEvent event) async {
    final updated = event.copyWith(isDone: !event.isDone);

    final events = widget.data.events.map((item) {
      return item.id == event.id ? updated : item;
    }).toList();

    await widget.onDataChanged(widget.data.copyWith(events: events));

    setState(() {});
  }

  Future<void> _deleteEvent(CalendarEvent event) async {
    final events = widget.data.events.where((item) => item.id != event.id).toList();

    await widget.onDataChanged(widget.data.copyWith(events: events));

    setState(() {});
  }

  void _openLinkedRepair(CalendarEvent event) {
    if (event.repairId.isEmpty) return;

    Repair? repair;

    for (final item in widget.data.repairs) {
      if (item.id == event.repairId) {
        repair = item;
        break;
      }
    }

    if (repair == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dossier lié introuvable.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepairDetailScreen(
          data: widget.data,
          repair: repair!,
          onDataChanged: widget.onDataChanged,
        ),
      ),
    );
  }

  void _openEventActions(CalendarEvent event) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              event.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text('${event.date} ${event.time}'.trim()),
            const SizedBox(height: 14),
            ListTile(
              leading: Icon(event.isDone ? Icons.undo : Icons.check_circle),
              title: Text(event.isDone ? 'Marquer non fait' : 'Marquer comme fait'),
              onTap: () {
                Navigator.pop(context);
                _toggleDone(event);
              },
            ),
            if (event.repairId.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.build),
                title: const Text('Ouvrir le dossier lié'),
                onTap: () {
                  Navigator.pop(context);
                  _openLinkedRepair(event);
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                _editEvent(event);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                _deleteEvent(event);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _dayCell(DateTime? date) {
    if (date == null) {
      return const SizedBox();
    }

    final events = eventsForDay(date);
    final selected = isSameDay(date, selectedDay);
    final today = isSameDay(date, DateTime.now());

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          selectedDay = date;
        });
      },
      onLongPress: () => _newEvent(date: date),
      child: Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : today
                  ? Colors.blue.shade50
                  : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            if (events.isNotEmpty)
              Wrap(
                spacing: 2,
                runSpacing: 2,
                children: events.take(4).map(
                  (event) {
                    return Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: event.isDone
                            ? Colors.green
                            : event.repairId.isEmpty
                                ? Colors.orange
                                : Colors.blue,
                      ),
                    );
                  },
                ).toList(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = eventsForDay(selectedDay);
    final cells = monthCells();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
            onPressed: () => _newEvent(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newEvent(),
        icon: const Icon(Icons.add),
        label: const Text('Événement'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: previousMonth,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            monthLabel(visibleMonth),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: nextMonth,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      _WeekDay('L'),
                      _WeekDay('M'),
                      _WeekDay('M'),
                      _WeekDay('J'),
                      _WeekDay('V'),
                      _WeekDay('S'),
                      _WeekDay('D'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cells.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 0.82,
                    ),
                    itemBuilder: (context, index) {
                      return _dayCell(cells[index]);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Événements du ${Formatters.date(selectedDay)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          if (selectedEvents.isEmpty)
            const EmptyStateCard(
              message: 'Aucun événement pour ce jour.',
              icon: Icons.event_available,
            )
          else
            ...selectedEvents.map(
              (event) => Card(
                child: ListTile(
                  onTap: () => _openEventActions(event),
                  leading: Icon(
                    event.isDone
                        ? Icons.check_circle
                        : event.repairId.isEmpty
                            ? Icons.event
                            : Icons.build,
                    color: event.isDone ? Colors.green : null,
                  ),
                  title: Text(
                    event.title,
                    style: TextStyle(
                      decoration: event.isDone ? TextDecoration.lineThrough : null,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.description.isEmpty ? event.type : event.description),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 6,
                        children: [
                          StatusBadge(label: event.type),
                          if (event.repairId.isEmpty)
                            const StatusBadge(label: 'Libre')
                          else
                            const StatusBadge(label: 'Dossier'),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text(event.time),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekDay extends StatelessWidget {
  final String label;

  const _WeekDay(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

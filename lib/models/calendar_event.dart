class CalendarEvent {
  final String id;
  final String repairId;
  final String clientId;
  final String title;
  final String description;
  final String type;
  final String date;
  final String time;
  final bool isDone;
  final String createdAt;

  const CalendarEvent({
    required this.id,
    required this.repairId,
    required this.clientId,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    required this.time,
    required this.isDone,
    required this.createdAt,
  });

  bool get hasRepair {
    return repairId.isNotEmpty;
  }

  CalendarEvent copyWith({
    String? title,
    String? description,
    String? type,
    String? date,
    String? time,
    bool? isDone,
  }) {
    return CalendarEvent(
      id: id,
      repairId: repairId,
      clientId: clientId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'repairId': repairId,
      'clientId': clientId,
      'title': title,
      'description': description,
      'type': type,
      'date': date,
      'time': time,
      'isDone': isDone,
      'createdAt': createdAt,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] ?? '',
      repairId: json['repairId'] ?? '',
      clientId: json['clientId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'Autre',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      isDone: json['isDone'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }
}

import 'calendar_event.dart';
import 'client.dart';
import 'repair.dart';
import 'shop_profile.dart';

class AppData {
  final List<Client> clients;
  final List<Repair> repairs;
  final List<CalendarEvent> events;
  final ShopProfile shopProfile;

  const AppData({
    required this.clients,
    required this.repairs,
    required this.events,
    required this.shopProfile,
  });

  factory AppData.empty() {
    return AppData(
      clients: const [],
      repairs: const [],
      events: const [],
      shopProfile: ShopProfile.defaultProfile(),
    );
  }

  AppData copyWith({
    List<Client>? clients,
    List<Repair>? repairs,
    List<CalendarEvent>? events,
    ShopProfile? shopProfile,
  }) {
    return AppData(
      clients: clients ?? this.clients,
      repairs: repairs ?? this.repairs,
      events: events ?? this.events,
      shopProfile: shopProfile ?? this.shopProfile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clients': clients.map((client) => client.toJson()).toList(),
      'repairs': repairs.map((repair) => repair.toJson()).toList(),
      'events': events.map((event) => event.toJson()).toList(),
      'shopProfile': shopProfile.toJson(),
    };
  }

  factory AppData.fromJson(Map<String, dynamic> json) {
    return AppData(
      clients: (json['clients'] as List<dynamic>? ?? [])
          .map((item) => Client.fromJson(item))
          .toList(),
      repairs: (json['repairs'] as List<dynamic>? ?? [])
          .map((item) => Repair.fromJson(item))
          .toList(),
      events: (json['events'] as List<dynamic>? ?? [])
          .map((item) => CalendarEvent.fromJson(item))
          .toList(),
      shopProfile: json['shopProfile'] == null
          ? ShopProfile.defaultProfile()
          : ShopProfile.fromJson(json['shopProfile']),
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/app_data.dart';
import '../models/calendar_event.dart';
import '../models/client.dart';
import '../models/repair.dart';

class StorageService {
  static Future<Directory> _directory() async {
    return getApplicationDocumentsDirectory();
  }

  static Future<File> _dataFile() async {
    final directory = await _directory();
    return File('${directory.path}/reparphone_v3_data.json');
  }

  static Future<AppData> loadData() async {
    try {
      final file = await _dataFile();

      if (!await file.exists()) {
        return AppData.empty();
      }

      final content = await file.readAsString();

      if (content.trim().isEmpty) {
        return AppData.empty();
      }

      return AppData.fromJson(jsonDecode(content));
    } catch (_) {
      return AppData.empty();
    }
  }

  static Future<void> saveData(AppData data) async {
    final file = await _dataFile();
    await file.writeAsString(jsonEncode(data.toJson()));
  }

  static String nextRepairId(List<Repair> repairs) {
    final year = DateTime.now().year;
    int maxNumber = 0;

    for (final repair in repairs) {
      final parts = repair.id.split('-');

      if (parts.length == 3) {
        final parsedYear = int.tryParse(parts[1]);
        final parsedNumber = int.tryParse(parts[2]);

        if (parsedYear == year && parsedNumber != null) {
          if (parsedNumber > maxNumber) {
            maxNumber = parsedNumber;
          }
        }
      }
    }

    return Repair.buildId(year: year, number: maxNumber + 1);
  }

  static String nextClientId(List<Client> clients) {
    return 'CLI-${DateTime.now().millisecondsSinceEpoch}';
  }

  static String nextEventId(List<CalendarEvent> events) {
    return 'EVT-${DateTime.now().millisecondsSinceEpoch}';
  }
}

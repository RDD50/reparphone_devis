import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/repair.dart';
import '../models/shop_settings.dart';

class StorageService {
  static Future<Directory> _directory() async {
    return getApplicationDocumentsDirectory();
  }

  static Future<File> _repairsFile() async {
    final directory = await _directory();
    return File('${directory.path}/repairs_v2.json');
  }

  static Future<File> _settingsFile() async {
    final directory = await _directory();
    return File('${directory.path}/shop_settings_v2.json');
  }

  static Future<List<Repair>> loadRepairs() async {
    try {
      final file = await _repairsFile();

      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();

      if (content.trim().isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(content);

      return data
          .map((item) => Repair.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveRepairs(List<Repair> repairs) async {
    final file = await _repairsFile();
    final data = repairs.map((repair) => repair.toJson()).toList();
    await file.writeAsString(jsonEncode(data));
  }

  static Future<ShopSettings> loadSettings() async {
    try {
      final file = await _settingsFile();

      if (!await file.exists()) {
        return ShopSettings.defaultSettings();
      }

      final content = await file.readAsString();

      if (content.trim().isEmpty) {
        return ShopSettings.defaultSettings();
      }

      return ShopSettings.fromJson(jsonDecode(content));
    } catch (_) {
      return ShopSettings.defaultSettings();
    }
  }

  static Future<void> saveSettings(ShopSettings settings) async {
    final file = await _settingsFile();
    await file.writeAsString(jsonEncode(settings.toJson()));
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

    return Repair.buildId(
      year: year,
      number: maxNumber + 1,
    );
  }
}

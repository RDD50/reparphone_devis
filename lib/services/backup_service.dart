import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/app_data.dart';

class BackupService {
  static String exportToJson(AppData data) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data.toJson());
  }

  static AppData importFromJson(String rawJson) {
    final decoded = jsonDecode(rawJson);
    return AppData.fromJson(decoded);
  }

  static Future<File> saveBackupFile(AppData data) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'reparphone_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${directory.path}/$fileName');

    await file.writeAsString(exportToJson(data));
    return file;
  }
}

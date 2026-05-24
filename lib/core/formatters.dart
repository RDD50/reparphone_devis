import 'package:intl/intl.dart';

class Formatters {
  static String money(double value) {
    return '${value.toStringAsFixed(2)} €';
  }

  static String date(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String monthTitle(DateTime date) {
    return DateFormat('MMMM yyyy', 'fr_FR').format(date);
  }

  static double parseAmount(String value) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0;
  }
}

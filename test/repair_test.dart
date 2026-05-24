import 'package:flutter_test/flutter_test.dart';
import 'package:reparphone_devis/models/repair.dart';

void main() {
  test('Le reste à payer est calculé correctement', () {
    final repair = Repair(
      id: 'REP-2025-0001',
      clientName: 'Client Test',
      clientPhone: '0600000000',
      brand: 'Apple',
      model: 'iPhone 12',
      imei: '',
      deviceState: 'Écran cassé',
      accessories: 'Aucun',
      problem: 'Écran noir',
      repairType: 'Remplacement écran',
      totalPrice: 120,
      deposit: 30,
      warranty: '3 mois',
      status: 'En attente',
      depositDate: '01/01/2025',
      returnDate: '03/01/2025',
      createdAt: DateTime.now().toIso8601String(),
    );

    expect(repair.remaining, 90);
  });

  test('Un statut livré n’est pas actif', () {
    final repair = Repair(
      id: 'REP-2025-0002',
      clientName: 'Client Test',
      clientPhone: '0600000000',
      brand: 'Samsung',
      model: 'S22',
      imei: '',
      deviceState: '',
      accessories: '',
      problem: '',
      repairType: 'Diagnostic',
      totalPrice: 50,
      deposit: 50,
      warranty: '3 mois',
      status: 'Livré',
      depositDate: '01/01/2025',
      returnDate: '03/01/2025',
      createdAt: DateTime.now().toIso8601String(),
    );

    expect(repair.isActive, false);
  });

  test('Le numéro de dossier est généré au bon format', () {
    final id = Repair.buildId(year: 2025, number: 7);

    expect(id, 'REP-2025-0007');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:reparphone_devis/models/app_data.dart';
import 'package:reparphone_devis/models/calendar_event.dart';
import 'package:reparphone_devis/models/client.dart';
import 'package:reparphone_devis/models/payment_info.dart';
import 'package:reparphone_devis/models/repair.dart';
import 'package:reparphone_devis/models/shop_profile.dart';

Repair buildRepair({
  String id = 'REP-2026-0001',
  String status = 'En attente',
  String paymentStatus = 'Non payé',
  double totalPrice = 120,
  double deposit = 30,
}) {
  return Repair(
    id: id,
    clientId: 'CLI-1',
    clientName: 'Client Test',
    clientPhone: '0600000000',
    brand: 'Apple',
    model: 'iPhone 12',
    imei: '',
    deviceState: '',
    accessories: '',
    problem: 'Ecran casse',
    repairType: 'Diagnostic',
    totalPrice: totalPrice,
    deposit: deposit,
    warranty: '3 mois',
    status: status,
    depositDate: '01/01/2026',
    returnDate: '03/01/2026',
    createdAt: '2026-01-01T10:00:00',
    paymentInfo: PaymentInfo(
      status: paymentStatus,
      method: 'Espèces',
      paymentDate: '',
    ),
  );
}

void main() {
  test('Le reste brut est calcule correctement', () {
    final repair = buildRepair(totalPrice: 120, deposit: 30);

    expect(repair.remaining, 90);
  });

  test('Un dossier livre nest pas actif', () {
    final repair = buildRepair(status: 'Livré');

    expect(repair.isActive, false);
  });

  test('Un dossier termine nest pas en cours', () {
    final repair = buildRepair(status: 'Terminé');

    expect(repair.isActive, false);
  });

  test('Un dossier paye est reconnu comme paye', () {
    final repair = buildRepair(paymentStatus: 'Payé');

    expect(repair.isPaid, true);
  });

  test('Le numero de dossier est genere au bon format', () {
    final id = Repair.buildId(year: 2026, number: 7);

    expect(id, 'REP-2026-0007');
  });

  test('Non paye signifie aucun encaissement', () {
    final repair = buildRepair(
      paymentStatus: 'Non payé',
      totalPrice: 120,
      deposit: 30,
    );

    expect(repair.collectedAmount, 0);
    expect(repair.remainingDue, 120);
  });

  test('Acompte verse signifie acompte encaisse', () {
    final repair = buildRepair(
      paymentStatus: 'Acompte versé',
      totalPrice: 120,
      deposit: 30,
    );

    expect(repair.collectedAmount, 30);
    expect(repair.remainingDue, 90);
  });

  test('Paye signifie total encaisse et aucun reste du', () {
    final repair = buildRepair(
      paymentStatus: 'Payé',
      totalPrice: 120,
      deposit: 30,
    );

    expect(repair.collectedAmount, 120);
    expect(repair.remainingDue, 0);
  });

  test('Rembourse signifie aucun encaissement et aucun reste du', () {
    final repair = buildRepair(
      paymentStatus: 'Remboursé',
      totalPrice: 120,
      deposit: 30,
    );

    expect(repair.collectedAmount, 0);
    expect(repair.remainingDue, 0);
  });

  test('Les donnees globales sont exportables en JSON', () {
    final data = AppData(
      clients: [
        Client(
          id: 'CLI-1',
          name: 'Client Test',
          phone: '0600000000',
          email: '',
          address: '',
          notes: '',
          createdAt: '2026-01-01T10:00:00',
        ),
      ],
      repairs: [buildRepair()],
      events: const [
        CalendarEvent(
          id: 'EVT-1',
          repairId: 'REP-2026-0001',
          clientId: 'CLI-1',
          title: 'Prise en charge',
          description: '',
          type: 'Prise en charge',
          date: '01/01/2026',
          time: '',
          isDone: false,
          createdAt: '2026-01-01T10:00:00',
        ),
      ],
      shopProfile: ShopProfile.defaultProfile(),
    );

    final json = data.toJson();

    expect(json['clients'], isA<List>());
    expect(json['repairs'], isA<List>());
    expect(json['events'], isA<List>());
    expect(json['shopProfile'], isA<Map<String, dynamic>>());
  });
}

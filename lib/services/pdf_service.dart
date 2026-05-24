import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/repair.dart';
import '../models/shop_profile.dart';

class PdfService {
  static String _money(double value) {
    return '${value.toStringAsFixed(2)} EUR';
  }

  static pw.Widget _title(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 135,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value.isEmpty ? '-' : value),
          ),
        ],
      ),
    );
  }

  static Future<Uint8List> buildRepairPdf({
    required Repair repair,
    required ShopProfile profile,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        profile.shopName,
                        style: pw.TextStyle(
                          fontSize: 21,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (profile.commercialText.isNotEmpty)
                        pw.Text(profile.commercialText),
                      if (profile.ownerName.isNotEmpty)
                        pw.Text('Responsable : ${profile.ownerName}'),
                      if (profile.phone.isNotEmpty)
                        pw.Text('Tel : ${profile.phone}'),
                      if (profile.email.isNotEmpty)
                        pw.Text('Email : ${profile.email}'),
                      if (profile.address.isNotEmpty)
                        pw.Text(profile.address),
                      if (profile.siret.isNotEmpty)
                        pw.Text('SIRET : ${profile.siret}'),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey600),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        repair.id,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Statut : ${repair.status}'),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Center(
              child: pw.Text(
                'RECU DE DEPOT / DEVIS DE REPARATION',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            _title('Client'),
            _row('Nom', repair.clientName),
            _row('Telephone', repair.clientPhone),
            _title('Appareil'),
            _row('Marque', repair.brand),
            _row('Modele', repair.model),
            _row('IMEI', repair.imei),
            _row('Etat arrivee', repair.deviceState),
            _row('Accessoires', repair.accessories),
            _title('Intervention'),
            _row('Probleme', repair.problem),
            _row('Reparation', repair.repairType),
            _row('Statut dossier', repair.status),
            _row('Date depot', repair.depositDate),
            _row('Date restitution', repair.returnDate),
            _row('Garantie', repair.warranty),
            _title('Paiement'),
            _row('Prix total', _money(repair.totalPrice)),
            _row('Acompte', _money(repair.deposit)),
            _row('Reste a payer', _money(repair.remaining)),
            _row('Statut paiement', repair.paymentInfo.status),
            _row('Mode paiement', repair.paymentInfo.method),
            _row('Date paiement', repair.paymentInfo.paymentDate),
            _title('Conditions'),
            pw.Text(profile.termsText),
            pw.SizedBox(height: 8),
            pw.Text(profile.warrantyText),
            pw.SizedBox(height: 34),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  width: 210,
                  height: 80,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey600),
                  ),
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Signature client'),
                  ),
                ),
                pw.Container(
                  width: 210,
                  height: 80,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey600),
                  ),
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Signature reparateur'),
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  static Future<void> shareRepairPdf({
    required Repair repair,
    required ShopProfile profile,
  }) async {
    final bytes = await buildRepairPdf(
      repair: repair,
      profile: profile,
    );

    await Printing.sharePdf(
      bytes: bytes,
      filename: '${repair.id}_${repair.clientName}.pdf',
    );
  }

  static Future<File> saveRepairPdf({
    required Repair repair,
    required ShopProfile profile,
  }) async {
    final bytes = await buildRepairPdf(
      repair: repair,
      profile: profile,
    );

    final directory = await getApplicationDocumentsDirectory();
    final safeClientName = repair.clientName.replaceAll(' ', '_');
    final file = File('${directory.path}/${repair.id}_$safeClientName.pdf');

    await file.writeAsBytes(bytes);
    return file;
  }
}

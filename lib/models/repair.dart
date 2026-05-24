class Repair {
  final String id;
  final String clientName;
  final String clientPhone;
  final String brand;
  final String model;
  final String imei;
  final String deviceState;
  final String accessories;
  final String problem;
  final String repairType;
  final double totalPrice;
  final double deposit;
  final String warranty;
  final String status;
  final String depositDate;
  final String returnDate;
  final String createdAt;

  const Repair({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    required this.brand,
    required this.model,
    required this.imei,
    required this.deviceState,
    required this.accessories,
    required this.problem,
    required this.repairType,
    required this.totalPrice,
    required this.deposit,
    required this.warranty,
    required this.status,
    required this.depositDate,
    required this.returnDate,
    required this.createdAt,
  });

  double get remaining => totalPrice - deposit;

  bool get isActive {
    return status != 'Livré' && status != 'Annulé';
  }

  bool get isFinished {
    return status == 'Terminé' || status == 'Livré';
  }

  Repair copyWith({
    String? status,
  }) {
    return Repair(
      id: id,
      clientName: clientName,
      clientPhone: clientPhone,
      brand: brand,
      model: model,
      imei: imei,
      deviceState: deviceState,
      accessories: accessories,
      problem: problem,
      repairType: repairType,
      totalPrice: totalPrice,
      deposit: deposit,
      warranty: warranty,
      status: status ?? this.status,
      depositDate: depositDate,
      returnDate: returnDate,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'brand': brand,
      'model': model,
      'imei': imei,
      'deviceState': deviceState,
      'accessories': accessories,
      'problem': problem,
      'repairType': repairType,
      'totalPrice': totalPrice,
      'deposit': deposit,
      'warranty': warranty,
      'status': status,
      'depositDate': depositDate,
      'returnDate': returnDate,
      'createdAt': createdAt,
    };
  }

  factory Repair.fromJson(Map<String, dynamic> json) {
    return Repair(
      id: json['id'] ?? '',
      clientName: json['clientName'] ?? '',
      clientPhone: json['clientPhone'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      imei: json['imei'] ?? '',
      deviceState: json['deviceState'] ?? '',
      accessories: json['accessories'] ?? '',
      problem: json['problem'] ?? '',
      repairType: json['repairType'] ?? 'Diagnostic',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      deposit: (json['deposit'] ?? 0).toDouble(),
      warranty: json['warranty'] ?? '3 mois',
      status: json['status'] ?? 'En attente',
      depositDate: json['depositDate'] ?? '',
      returnDate: json['returnDate'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  static String buildId({
    required int year,
    required int number,
  }) {
    return 'REP-$year-${number.toString().padLeft(4, '0')}';
  }
}

const List<String> repairStatuses = [
  'En attente',
  'En réparation',
  'En attente de pièce',
  'Terminé',
  'Livré',
  'Annulé',
];

const List<String> repairTypes = [
  'Diagnostic',
  'Remplacement écran',
  'Remplacement batterie',
  'Connecteur de charge',
  'Caméra',
  'Haut-parleur',
  'Micro',
  'Désoxydation',
  'Réinitialisation logiciel',
  'Sauvegarde données',
  'Pose protection écran',
  'Autre réparation',
];

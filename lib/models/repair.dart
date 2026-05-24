import 'payment_info.dart';

class Repair {
  final String id;
  final String clientId;
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
  final PaymentInfo paymentInfo;

  const Repair({
    required this.id,
    required this.clientId,
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
    required this.paymentInfo,
  });

  double get remaining {
    final value = totalPrice - deposit;
    return value < 0 ? 0 : value;
  }

  double get remainingDue {
    if (paymentInfo.status == 'Payé') {
      return 0;
    }

    if (paymentInfo.status == 'Remboursé') {
      return 0;
    }

    return remaining;
  }

  double get collectedAmount {
    if (paymentInfo.status == 'Payé') {
      return totalPrice;
    }

    if (paymentInfo.status == 'Remboursé') {
      return 0;
    }

    return deposit;
  }

  bool get isActive {
    return status == 'En attente' ||
        status == 'En réparation' ||
        status == 'En attente de pièce';
  }

  bool get isFinished {
    return status == 'Terminé' || status == 'Livré';
  }

  bool get isPaid {
    return paymentInfo.status == 'Payé';
  }

  Repair copyWith({
    String? clientId,
    String? clientName,
    String? clientPhone,
    String? brand,
    String? model,
    String? imei,
    String? deviceState,
    String? accessories,
    String? problem,
    String? repairType,
    double? totalPrice,
    double? deposit,
    String? warranty,
    String? status,
    String? depositDate,
    String? returnDate,
    PaymentInfo? paymentInfo,
  }) {
    return Repair(
      id: id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      imei: imei ?? this.imei,
      deviceState: deviceState ?? this.deviceState,
      accessories: accessories ?? this.accessories,
      problem: problem ?? this.problem,
      repairType: repairType ?? this.repairType,
      totalPrice: totalPrice ?? this.totalPrice,
      deposit: deposit ?? this.deposit,
      warranty: warranty ?? this.warranty,
      status: status ?? this.status,
      depositDate: depositDate ?? this.depositDate,
      returnDate: returnDate ?? this.returnDate,
      createdAt: createdAt,
      paymentInfo: paymentInfo ?? this.paymentInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
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
      'paymentInfo': paymentInfo.toJson(),
    };
  }

  factory Repair.fromJson(Map<String, dynamic> json) {
    return Repair(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
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
      paymentInfo: json['paymentInfo'] == null
          ? PaymentInfo.empty()
          : PaymentInfo.fromJson(json['paymentInfo']),
    );
  }

  static String buildId({
    required int year,
    required int number,
  }) {
    return 'REP-$year-${number.toString().padLeft(4, '0')}';
  }
}

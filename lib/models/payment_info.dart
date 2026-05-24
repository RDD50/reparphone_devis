class PaymentInfo {
  final String status;
  final String method;
  final String paymentDate;

  const PaymentInfo({
    required this.status,
    required this.method,
    required this.paymentDate,
  });

  factory PaymentInfo.empty() {
    return const PaymentInfo(
      status: 'Non payé',
      method: 'Espèces',
      paymentDate: '',
    );
  }

  PaymentInfo copyWith({
    String? status,
    String? method,
    String? paymentDate,
  }) {
    return PaymentInfo(
      status: status ?? this.status,
      method: method ?? this.method,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'method': method,
      'paymentDate': paymentDate,
    };
  }

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      status: json['status'] ?? 'Non payé',
      method: json['method'] ?? 'Espèces',
      paymentDate: json['paymentDate'] ?? '',
    );
  }
}

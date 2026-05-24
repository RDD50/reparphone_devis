class ShopSettings {
  final String shopName;
  final String ownerName;
  final String phone;
  final String email;
  final String address;
  final String siret;
  final String warrantyText;
  final String termsText;

  const ShopSettings({
    required this.shopName,
    required this.ownerName,
    required this.phone,
    required this.email,
    required this.address,
    required this.siret,
    required this.warrantyText,
    required this.termsText,
  });

  factory ShopSettings.defaultSettings() {
    return const ShopSettings(
      shopName: 'Ma boutique de réparation',
      ownerName: '',
      phone: '',
      email: '',
      address: '',
      siret: '',
      warrantyText: 'Garantie 3 mois hors casse, oxydation et mauvaise utilisation.',
      termsText: 'Le client reconnaît déposer son appareil pour diagnostic ou réparation. Les données personnelles doivent être sauvegardées par le client avant intervention.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopName': shopName,
      'ownerName': ownerName,
      'phone': phone,
      'email': email,
      'address': address,
      'siret': siret,
      'warrantyText': warrantyText,
      'termsText': termsText,
    };
  }

  factory ShopSettings.fromJson(Map<String, dynamic> json) {
    return ShopSettings(
      shopName: json['shopName'] ?? 'Ma boutique de réparation',
      ownerName: json['ownerName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      siret: json['siret'] ?? '',
      warrantyText: json['warrantyText'] ??
          'Garantie 3 mois hors casse, oxydation et mauvaise utilisation.',
      termsText: json['termsText'] ??
          'Le client reconnaît déposer son appareil pour diagnostic ou réparation.',
    );
  }
}

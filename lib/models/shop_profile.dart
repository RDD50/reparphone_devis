class ShopProfile {
  final String appDisplayName;
  final String shopName;
  final String ownerName;
  final String phone;
  final String email;
  final String address;
  final String siret;
  final String primaryColorHex;
  final String warrantyText;
  final String termsText;
  final String commercialText;

  const ShopProfile({
    required this.appDisplayName,
    required this.shopName,
    required this.ownerName,
    required this.phone,
    required this.email,
    required this.address,
    required this.siret,
    required this.primaryColorHex,
    required this.warrantyText,
    required this.termsText,
    required this.commercialText,
  });

  factory ShopProfile.defaultProfile() {
    return const ShopProfile(
      appDisplayName: 'ReparPhone Devis',
      shopName: 'Ma boutique de réparation',
      ownerName: '',
      phone: '',
      email: '',
      address: '',
      siret: '',
      primaryColorHex: '#243B80',
      warrantyText: 'Garantie 3 mois hors casse, oxydation et mauvaise utilisation.',
      termsText: 'Le client reconnaît déposer son appareil pour diagnostic ou réparation. Les données personnelles doivent être sauvegardées par le client avant intervention.',
      commercialText: 'Réparation, diagnostic et suivi de smartphone.',
    );
  }

  ShopProfile copyWith({
    String? appDisplayName,
    String? shopName,
    String? ownerName,
    String? phone,
    String? email,
    String? address,
    String? siret,
    String? primaryColorHex,
    String? warrantyText,
    String? termsText,
    String? commercialText,
  }) {
    return ShopProfile(
      appDisplayName: appDisplayName ?? this.appDisplayName,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      siret: siret ?? this.siret,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      warrantyText: warrantyText ?? this.warrantyText,
      termsText: termsText ?? this.termsText,
      commercialText: commercialText ?? this.commercialText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appDisplayName': appDisplayName,
      'shopName': shopName,
      'ownerName': ownerName,
      'phone': phone,
      'email': email,
      'address': address,
      'siret': siret,
      'primaryColorHex': primaryColorHex,
      'warrantyText': warrantyText,
      'termsText': termsText,
      'commercialText': commercialText,
    };
  }

  factory ShopProfile.fromJson(Map<String, dynamic> json) {
    return ShopProfile(
      appDisplayName: json['appDisplayName'] ?? 'ReparPhone Devis',
      shopName: json['shopName'] ?? 'Ma boutique de réparation',
      ownerName: json['ownerName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      siret: json['siret'] ?? '',
      primaryColorHex: json['primaryColorHex'] ?? '#243B80',
      warrantyText: json['warrantyText'] ??
          'Garantie 3 mois hors casse, oxydation et mauvaise utilisation.',
      termsText: json['termsText'] ??
          'Le client reconnaît déposer son appareil pour diagnostic ou réparation.',
      commercialText: json['commercialText'] ??
          'Réparation, diagnostic et suivi de smartphone.',
    );
  }
}

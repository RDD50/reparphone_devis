class Client {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String notes;
  final String createdAt;

  const Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.notes,
    required this.createdAt,
  });

  Client copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
      'createdAt': createdAt,
    };
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

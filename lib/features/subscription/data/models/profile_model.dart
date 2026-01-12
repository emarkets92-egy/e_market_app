class ProfileModel {
  final String id;
  final String? companyName;
  final String? email;
  final String? phone;
  final String? whatsapp;
  final String? website;
  final String? address;
  final String? countryName;
  final int? shipmentRecords;
  final bool isSeen;
  final int unlockCost;
  final DateTime? unlockedAt;

  ProfileModel({
    required this.id,
    this.companyName,
    this.email,
    this.phone,
    this.whatsapp,
    this.website,
    this.address,
    this.countryName,
    this.shipmentRecords,
    required this.isSeen,
    required this.unlockCost,
    this.unlockedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      companyName: json['companyName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      countryName: json['countryName'] as String?,
      shipmentRecords: json['shipmentRecords'] != null ? (json['shipmentRecords'] as num).toInt() : null,
      isSeen: json['isSeen'] as bool? ?? false,
      unlockCost: json['unlockCost'] != null ? (json['unlockCost'] as num).toInt() : 0, // Default to 0 if not provided (e.g., in unlock response)
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (companyName != null) 'companyName': companyName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (website != null) 'website': website,
      if (address != null) 'address': address,
      if (countryName != null) 'countryName': countryName,
      if (shipmentRecords != null) 'shipmentRecords': shipmentRecords,
      'isSeen': isSeen,
      'unlockCost': unlockCost,
      if (unlockedAt != null) 'unlockedAt': unlockedAt!.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? companyName,
    String? email,
    String? phone,
    String? whatsapp,
    String? website,
    String? address,
    String? countryName,
    int? shipmentRecords,
    bool? isSeen,
    int? unlockCost,
    DateTime? unlockedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      website: website ?? this.website,
      address: address ?? this.address,
      countryName: countryName ?? this.countryName,
      shipmentRecords: shipmentRecords ?? this.shipmentRecords,
      isSeen: isSeen ?? this.isSeen,
      unlockCost: unlockCost ?? this.unlockCost,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

class ProfileModel {
  final String id;
  final String? email;
  final String? phone;
  final String? whatsapp;
  final String? website;
  final String? address;
  final int? shipmentRecords;
  final bool isSeen;
  final int unlockCost;

  ProfileModel({
    required this.id,
    this.email,
    this.phone,
    this.whatsapp,
    this.website,
    this.address,
    this.shipmentRecords,
    required this.isSeen,
    required this.unlockCost,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      shipmentRecords: json['shipmentRecords'] != null
          ? (json['shipmentRecords'] as num).toInt()
          : null,
      isSeen: json['isSeen'] as bool,
      unlockCost: (json['unlockCost'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (website != null) 'website': website,
      if (address != null) 'address': address,
      if (shipmentRecords != null) 'shipmentRecords': shipmentRecords,
      'isSeen': isSeen,
      'unlockCost': unlockCost,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? whatsapp,
    String? website,
    String? address,
    int? shipmentRecords,
    bool? isSeen,
    int? unlockCost,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      website: website ?? this.website,
      address: address ?? this.address,
      shipmentRecords: shipmentRecords ?? this.shipmentRecords,
      isSeen: isSeen ?? this.isSeen,
      unlockCost: unlockCost ?? this.unlockCost,
    );
  }
}

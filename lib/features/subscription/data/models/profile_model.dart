import '../../../localization/data/models/country_model.dart';

class ProfileModel {
  final String id;
  final String? name;
  final String? companyName;
  final String? email;
  final String? phone;
  final String? whatsapp;
  final String? website;
  final String? address;
  final CountryModel? country;
  final int? shipmentRecords;
  final bool isSeen;
  final int unlockCost;

  ProfileModel({
    required this.id,
    this.name,
    this.companyName,
    this.email,
    this.phone,
    this.whatsapp,
    this.website,
    this.address,
    this.country,
    this.shipmentRecords,
    required this.isSeen,
    required this.unlockCost,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      companyName: json['companyName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      country: json['country'] != null
          ? CountryModel.fromJson(json['country'] as Map<String, dynamic>)
          : null,
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
      if (name != null) 'name': name,
      if (companyName != null) 'companyName': companyName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (website != null) 'website': website,
      if (address != null) 'address': address,
      if (country != null) 'country': country!.toJson(),
      if (shipmentRecords != null) 'shipmentRecords': shipmentRecords,
      'isSeen': isSeen,
      'unlockCost': unlockCost,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? name,
    String? companyName,
    String? email,
    String? phone,
    String? whatsapp,
    String? website,
    String? address,
    CountryModel? country,
    int? shipmentRecords,
    bool? isSeen,
    int? unlockCost,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      website: website ?? this.website,
      address: address ?? this.address,
      country: country ?? this.country,
      shipmentRecords: shipmentRecords ?? this.shipmentRecords,
      isSeen: isSeen ?? this.isSeen,
      unlockCost: unlockCost ?? this.unlockCost,
    );
  }
}

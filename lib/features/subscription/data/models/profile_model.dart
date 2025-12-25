import '../../../localization/data/models/country_model.dart';

class ProfileModel {
  final String id;
  final String name;
  final String companyName;
  final String? email;
  final String? phone;
  final String? whatsapp;
  final String? website;
  final String? address;
  final CountryModel country;
  final bool isSeen;
  final int unlockCost;

  ProfileModel({
    required this.id,
    required this.name,
    required this.companyName,
    this.email,
    this.phone,
    this.whatsapp,
    this.website,
    this.address,
    required this.country,
    required this.isSeen,
    required this.unlockCost,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      companyName: json['companyName'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      country: CountryModel.fromJson(json['country'] as Map<String, dynamic>),
      isSeen: json['isSeen'] as bool,
      unlockCost: (json['unlockCost'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'companyName': companyName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (website != null) 'website': website,
      if (address != null) 'address': address,
      'country': country.toJson(),
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
      isSeen: isSeen ?? this.isSeen,
      unlockCost: unlockCost ?? this.unlockCost,
    );
  }
}

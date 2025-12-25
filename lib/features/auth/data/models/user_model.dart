class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? companyName;
  final String? phone;
  final String? whatsapp;
  final String? website;
  final String? address;
  final int? statusId;
  final int? userTypeId;
  final int countryId;
  final int points;
  final String publicId;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.companyName,
    this.phone,
    this.whatsapp,
    this.website,
    this.address,
    this.statusId,
    required this.userTypeId,
    required this.countryId,
    required this.points,
    required this.publicId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      companyName: json['companyName'] as String?,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      statusId: (json['statusId'] as num?)?.toInt(),
      userTypeId: (json['userTypeId'] as num?)?.toInt(),
      countryId: (json['countryId'] as num).toInt(),
      points: (json['points'] as num).toInt(),
      publicId: json['publicId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (name != null) 'name': name,
      if (companyName != null) 'companyName': companyName,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (website != null) 'website': website,
      if (address != null) 'address': address,
      if (statusId != null) 'statusId': statusId,
      if (userTypeId != null) 'userTypeId': userTypeId,
      'countryId': countryId,
      'points': points,
      'publicId': publicId,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? companyName,
    String? phone,
    String? whatsapp,
    String? website,
    String? address,
    int? statusId,
    int? userTypeId,
    int? countryId,
    int? points,
    String? publicId,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      website: website ?? this.website,
      address: address ?? this.address,
      statusId: statusId ?? this.statusId,
      userTypeId: userTypeId ?? this.userTypeId,
      countryId: countryId ?? this.countryId,
      points: points ?? this.points,
      publicId: publicId ?? this.publicId,
    );
  }
}

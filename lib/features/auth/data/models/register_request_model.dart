class RegisterRequestModel {
  final String email;
  final String password;
  final String? name;
  final String? companyName;
  final String? phone;
  final String? whatsapp;
  final String? website;
  final String? address;
  final int? statusId;
  final int? userTypeId;
  final int countryId;
  final String? fcmToken;

  RegisterRequestModel({
    required this.email,
    required this.password,
    this.name,
    this.companyName,
    this.phone,
    this.whatsapp,
    this.website,
    this.address,
    this.statusId,
    required this.userTypeId,
    required this.countryId,
    this.fcmToken,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    return RegisterRequestModel(
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String?,
      companyName: json['companyName'] as String?,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      statusId: (json['statusId'] as num?)?.toInt(),
      userTypeId: (json['userTypeId'] as num?)?.toInt(),
      countryId: (json['countryId'] as num).toInt(),
      fcmToken: json['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (name != null) 'name': name,
      if (companyName != null) 'companyName': companyName,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (website != null) 'website': website,
      if (address != null) 'address': address,
      if (statusId != null) 'statusId': statusId,
      if (userTypeId != null) 'userTypeId': userTypeId,
      'countryId': countryId,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }
}

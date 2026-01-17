class RegisterRequestModel {
  final String email; // Primary email (for backward compatibility)
  final String password;
  final String? name;
  final String? companyName;
  final String? phone; // Primary phone (for backward compatibility)
  final String? whatsapp; // Primary whatsapp (for backward compatibility)
  final String? website;
  final String? address; // Primary address (for backward compatibility)
  final int? statusId;
  final int? userTypeId;
  final int countryId;
  final String? fcmToken;
  final List<int>? countries; // Additional countries

  // Arrays for multiple values
  final List<String>? emails;
  final List<String>? phones;
  final List<String>? whatsapps;
  final List<String>? addresses;

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
    this.countries,
    this.emails,
    this.phones,
    this.whatsapps,
    this.addresses,
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
      countries: json['countries'] != null
          ? List<int>.from((json['countries'] as List).map((e) => (e as num).toInt()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Use arrays if provided, otherwise transform single values to arrays
    final List<String> emailsList = emails ?? [email];
    final List<String>? phonesList = phones ?? (phone != null && phone!.isNotEmpty ? [phone!] : null);
    final List<String>? whatsappsList = whatsapps ?? (whatsapp != null && whatsapp!.isNotEmpty ? [whatsapp!] : null);
    final List<String>? addressesList = addresses ?? (address != null && address!.isNotEmpty ? [address!] : null);

    return {
      'email': email,
      'password': password,
      'emails': emailsList, // Always send as array
      if (name != null) 'name': name,
      if (companyName != null) 'companyName': companyName,
      if (phonesList != null && phonesList.isNotEmpty) 'phones': phonesList,
      if (whatsappsList != null && whatsappsList.isNotEmpty) 'whatsapps': whatsappsList,
      if (addressesList != null && addressesList.isNotEmpty) 'addresses': addressesList,
      if (website != null) 'website': website,
      if (statusId != null) 'statusId': statusId,
      if (userTypeId != null) 'userTypeId': userTypeId,
      'countryId': countryId,
      if (countries != null && countries!.isNotEmpty) 'countries': countries,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }
}

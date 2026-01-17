class UserModel {
  final String id;
  final String publicId;
  final String? name;
  final String? companyName;
  final String? website;
  final int? statusId;
  final int? userTypeId;
  final int countryId;
  final int points;
  final bool isUserSubscribed;
  final String? fcmToken;
  final String? sourceType;

  // Arrays from API
  final List<String> emails;
  final List<String>? phones;
  final List<String>? whatsapps;
  final List<String>? addresses;
  final List<int>? countries;

  // Convenience getters for backward compatibility (returns first element)
  String get email => emails.isNotEmpty ? emails.first : '';
  String? get phone => phones != null && phones!.isNotEmpty ? phones!.first : null;
  String? get whatsapp => whatsapps != null && whatsapps!.isNotEmpty ? whatsapps!.first : null;
  String? get address => addresses != null && addresses!.isNotEmpty ? addresses!.first : null;

  UserModel({
    required this.id,
    required this.publicId,
    this.name,
    this.companyName,
    this.website,
    this.statusId,
    required this.userTypeId,
    required this.countryId,
    required this.points,
    required this.isUserSubscribed,
    this.fcmToken,
    this.sourceType,
    required this.emails,
    this.phones,
    this.whatsapps,
    this.addresses,
    this.countries,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle arrays from API, with fallback to single values for backward compatibility
    List<String> emails = [];
    if (json['emails'] != null) {
      emails = List<String>.from(json['emails'] as List);
    } else if (json['email'] != null) {
      emails = [json['email'] as String];
    }

    List<String>? phones;
    if (json['phones'] != null) {
      phones = List<String>.from(json['phones'] as List);
    } else if (json['phone'] != null) {
      phones = [json['phone'] as String];
    }

    List<String>? whatsapps;
    if (json['whatsapps'] != null) {
      whatsapps = List<String>.from(json['whatsapps'] as List);
    } else if (json['whatsapp'] != null) {
      whatsapps = [json['whatsapp'] as String];
    }

    List<String>? addresses;
    if (json['addresses'] != null) {
      addresses = List<String>.from(json['addresses'] as List);
    } else if (json['address'] != null) {
      addresses = [json['address'] as String];
    }

    List<int>? countries;
    if (json['countries'] != null) {
      countries = List<int>.from((json['countries'] as List).map((e) => (e as num).toInt()));
    }

    return UserModel(
      id: json['id'] as String,
      publicId: json['publicId'] as String,
      name: json['name'] as String?,
      companyName: json['companyName'] as String?,
      website: json['website'] as String?,
      statusId: (json['statusId'] as num?)?.toInt(),
      userTypeId: (json['userTypeId'] as num?)?.toInt(),
      countryId: (json['countryId'] as num).toInt(),
      points: (json['points'] as num?)?.toInt() ?? 0,
      isUserSubscribed: json['isUserSubscribed'] as bool? ?? false,
      fcmToken: json['fcmToken'] as String?,
      sourceType: json['sourceType'] as String?,
      emails: emails,
      phones: phones,
      whatsapps: whatsapps,
      addresses: addresses,
      countries: countries,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'publicId': publicId,
      'email': email, // Keep single email for backward compatibility
      'emails': emails, // Also include array
      if (name != null) 'name': name,
      if (companyName != null) 'companyName': companyName,
      if (phones != null) 'phones': phones,
      if (phone != null) 'phone': phone, // Keep single phone for backward compatibility
      if (whatsapps != null) 'whatsapps': whatsapps,
      if (whatsapp != null) 'whatsapp': whatsapp, // Keep single whatsapp for backward compatibility
      if (addresses != null) 'addresses': addresses,
      if (address != null) 'address': address, // Keep single address for backward compatibility
      if (website != null) 'website': website,
      if (statusId != null) 'statusId': statusId,
      if (userTypeId != null) 'userTypeId': userTypeId,
      'countryId': countryId,
      if (countries != null) 'countries': countries,
      'points': points,
      'isUserSubscribed': isUserSubscribed,
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (sourceType != null) 'sourceType': sourceType,
    };
  }

  UserModel copyWith({
    String? id,
    String? publicId,
    String? name,
    String? companyName,
    String? website,
    int? statusId,
    int? userTypeId,
    int? countryId,
    int? points,
    bool? isUserSubscribed,
    String? fcmToken,
    String? sourceType,
    List<String>? emails,
    List<String>? phones,
    List<String>? whatsapps,
    List<String>? addresses,
    List<int>? countries,
  }) {
    return UserModel(
      id: id ?? this.id,
      publicId: publicId ?? this.publicId,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      website: website ?? this.website,
      statusId: statusId ?? this.statusId,
      userTypeId: userTypeId ?? this.userTypeId,
      countryId: countryId ?? this.countryId,
      points: points ?? this.points,
      isUserSubscribed: isUserSubscribed ?? this.isUserSubscribed,
      fcmToken: fcmToken ?? this.fcmToken,
      sourceType: sourceType ?? this.sourceType,
      emails: emails ?? this.emails,
      phones: phones ?? this.phones,
      whatsapps: whatsapps ?? this.whatsapps,
      addresses: addresses ?? this.addresses,
      countries: countries ?? this.countries,
    );
  }
}

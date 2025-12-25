class UpdateProfileRequestModel {
  final String? name;
  final String? companyName;
  final String? phone;
  final String? whatsapp;
  final String? website;
  final String? address;
  final int? statusId;
  final int? userTypeId;
  final int? countryId;
  final String? fcmToken;

  UpdateProfileRequestModel({
    this.name,
    this.companyName,
    this.phone,
    this.whatsapp,
    this.website,
    this.address,
    this.statusId,
    this.userTypeId,
    this.countryId,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (companyName != null) json['companyName'] = companyName;
    if (phone != null) json['phone'] = phone;
    if (whatsapp != null) json['whatsapp'] = whatsapp;
    if (website != null) json['website'] = website;
    if (address != null) json['address'] = address;
    if (statusId != null) json['statusId'] = statusId;
    if (userTypeId != null) json['userTypeId'] = userTypeId;
    if (countryId != null) json['countryId'] = countryId;
    if (fcmToken != null) json['fcmToken'] = fcmToken;
    return json;
  }
}

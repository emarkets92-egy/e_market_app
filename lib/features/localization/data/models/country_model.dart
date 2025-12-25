class CountryModel {
  final int id;
  final String code;
  final String name;
  final String? iso3Code;
  final String? phoneCode;
  final String? flagEmoji;

  CountryModel({
    required this.id,
    required this.code,
    required this.name,
    this.iso3Code,
    this.phoneCode,
    this.flagEmoji,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      iso3Code: json['iso3Code'] as String?,
      phoneCode: json['phoneCode'] as String?,
      flagEmoji: json['flagEmoji'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      if (iso3Code != null) 'iso3Code': iso3Code,
      if (phoneCode != null) 'phoneCode': phoneCode,
      if (flagEmoji != null) 'flagEmoji': flagEmoji,
    };
  }
}

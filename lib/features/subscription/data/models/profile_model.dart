class ProfileModel {
  final String id;
  final String? companyName;
  final List<String> emails;
  final List<String> phones;
  final List<String> whatsapps;
  final String? website;
  final List<String> addresses;
  final int? countryId;
  final List<String> countries;
  final int? shipmentRecords;
  final bool isSeen;
  final int unlockCost;
  final DateTime? unlockedAt;

  /// First email, or null if none. For backward compatibility with UI.
  String? get email => emails.isNotEmpty ? emails.first : null;

  /// First phone, or null if none. For backward compatibility with UI.
  String? get phone => phones.isNotEmpty ? phones.first : null;

  /// First whatsapp, or null if none. For backward compatibility with UI.
  String? get whatsapp => whatsapps.isNotEmpty ? whatsapps.first : null;

  /// First address, or null if none. For backward compatibility with UI.
  String? get address => addresses.isNotEmpty ? addresses.first : null;

  /// First country name, or null if none. For backward compatibility with UI.
  String? get countryName => countries.isNotEmpty ? countries.first : null;

  ProfileModel({
    required this.id,
    this.companyName,
    List<String>? emails,
    List<String>? phones,
    List<String>? whatsapps,
    this.website,
    List<String>? addresses,
    this.countryId,
    List<String>? countries,
    this.shipmentRecords,
    required this.isSeen,
    required this.unlockCost,
    this.unlockedAt,
  })  : emails = emails ?? [],
        phones = phones ?? [],
        whatsapps = whatsapps ?? [],
        addresses = addresses ?? [],
        countries = countries ?? [];

  static String? _cleanNullableString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      if (trimmed.toLowerCase().contains('[object')) return null;
      return trimmed;
    }
    if (value is num) return value.toString();
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    return value
        .map((e) => _cleanNullableString(e))
        .whereType<String>()
        .toList();
  }

  static List<String> _parseCountriesList(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    return value.map((e) {
      if (e is String) return e.trim();
      if (e is Map) {
        final v = e['name'] ?? e['countryName'];
        return (v?.toString() ?? '').trim();
      }
      return (e?.toString() ?? '').trim();
    }).where((s) => s.isNotEmpty).toList();
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Prefer new structure (emails, phones, whatsapps, addresses, countries); fall back to old (email, phone, etc.) for migration.
    List<String> emails = _parseStringList(json['emails']);
    if (emails.isEmpty && json['email'] != null) {
      final s = _cleanNullableString(json['email']);
      if (s != null) emails = [s];
    }

    List<String> phones = _parseStringList(json['phones']);
    if (phones.isEmpty && json['phone'] != null) {
      final s = _cleanNullableString(json['phone']);
      if (s != null) phones = [s];
    }

    List<String> whatsapps = _parseStringList(json['whatsapps']);
    if (whatsapps.isEmpty && json['whatsapp'] != null) {
      final s = _cleanNullableString(json['whatsapp']);
      if (s != null) whatsapps = [s];
    }

    List<String> addresses = _parseStringList(json['addresses']);
    if (addresses.isEmpty && json['address'] != null) {
      final s = _cleanNullableString(json['address']);
      if (s != null) addresses = [s];
    }

    List<String> countries = _parseCountriesList(json['countries']);
    if (countries.isEmpty && json['countryName'] != null) {
      final s = _cleanNullableString(json['countryName']);
      if (s != null) countries = [s];
    }

    return ProfileModel(
      id: json['id'] as String,
      companyName: _cleanNullableString(json['companyName']),
      emails: emails,
      phones: phones,
      whatsapps: whatsapps,
      website: _cleanNullableString(json['website']),
      addresses: addresses,
      countryId: json['countryId'] != null ? (json['countryId'] as num).toInt() : null,
      countries: countries,
      shipmentRecords: json['shipmentRecords'] != null ? (json['shipmentRecords'] as num).toInt() : null,
      isSeen: json['isSeen'] as bool? ?? false,
      unlockCost: json['unlockCost'] != null ? (json['unlockCost'] as num).toInt() : 0,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (companyName != null) 'companyName': companyName,
      'emails': emails,
      'phones': phones,
      'whatsapps': whatsapps,
      if (website != null) 'website': website,
      'addresses': addresses,
      if (countryId != null) 'countryId': countryId,
      'countries': countries,
      if (shipmentRecords != null) 'shipmentRecords': shipmentRecords,
      'isSeen': isSeen,
      'unlockCost': unlockCost,
      if (unlockedAt != null) 'unlockedAt': unlockedAt!.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? companyName,
    List<String>? emails,
    List<String>? phones,
    List<String>? whatsapps,
    String? website,
    List<String>? addresses,
    int? countryId,
    List<String>? countries,
    int? shipmentRecords,
    bool? isSeen,
    int? unlockCost,
    DateTime? unlockedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      emails: emails ?? this.emails,
      phones: phones ?? this.phones,
      whatsapps: whatsapps ?? this.whatsapps,
      website: website ?? this.website,
      addresses: addresses ?? this.addresses,
      countryId: countryId ?? this.countryId,
      countries: countries ?? this.countries,
      shipmentRecords: shipmentRecords ?? this.shipmentRecords,
      isSeen: isSeen ?? this.isSeen,
      unlockCost: unlockCost ?? this.unlockCost,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

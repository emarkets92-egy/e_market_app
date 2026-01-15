class UnlockedProfileModel {
  final String profileId;
  final String? userId;
  final String? name;
  final String? companyName;
  final String? email;
  final int countryId;
  final String? countryName;
  final DateTime unlockedAt;
  final bool hasExistingChat;
  final String? roomId;

  UnlockedProfileModel({
    required this.profileId,
    this.userId,
    this.name,
    this.companyName,
    this.email,
    required this.countryId,
    this.countryName,
    required this.unlockedAt,
    required this.hasExistingChat,
    this.roomId,
  });

  factory UnlockedProfileModel.fromJson(Map<String, dynamic> json) {
    try {
      final profileId = json['profileId'];
      if (profileId == null) {
        throw Exception('profileId is null in JSON: $json');
      }
      final email = json['email'];
      final countryId = json['countryId'];
      if (countryId == null) {
        throw Exception('countryId is null in JSON: $json');
      }
      final unlockedAt = json['unlockedAt'];
      if (unlockedAt == null) {
        throw Exception('unlockedAt is null in JSON: $json');
      }
      return UnlockedProfileModel(
        profileId: profileId as String,
        userId: json['userId'] as String?,
        name: json['name'] as String?,
        companyName: json['companyName'] as String?,
        email: email as String?,
        countryId: (countryId as num).toInt(),
        countryName: json['countryName'] as String?,
        unlockedAt: DateTime.parse(unlockedAt as String),
        hasExistingChat: json['hasExistingChat'] as bool? ?? false,
        roomId: json['roomId'] as String?,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      if (userId != null) 'userId': userId,
      if (name != null) 'name': name,
      if (companyName != null) 'companyName': companyName,
      if (email != null) 'email': email,
      'countryId': countryId,
      if (countryName != null) 'countryName': countryName,
      'unlockedAt': unlockedAt.toIso8601String(),
      'hasExistingChat': hasExistingChat,
      if (roomId != null) 'roomId': roomId,
    };
  }

  String get displayName => name ?? companyName ?? email ?? 'Unknown';
}

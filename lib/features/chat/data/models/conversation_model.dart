import 'message_model.dart';

class ConversationParticipant {
  final String? userId;
  final String profileId;
  final String? name;
  final String? companyName;
  final String email;

  ConversationParticipant({this.userId, required this.profileId, this.name, this.companyName, required this.email});

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) {
    try {
      final profileId = json['profileId'];
      if (profileId == null) {
        throw Exception('profileId is null in JSON: $json');
      }

      final email = json['email'];
      if (email == null) {
        throw Exception('email is null in JSON: $json');
      }

      return ConversationParticipant(
        userId: json['userId'] as String?,
        profileId: profileId as String,
        name: json['name'] as String?,
        companyName: json['companyName'] as String?,
        email: email as String,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      'profileId': profileId,
      if (name != null) 'name': name,
      if (companyName != null) 'companyName': companyName,
      'email': email,
    };
  }

  ConversationParticipant copyWith({String? userId, String? profileId, String? name, String? companyName, String? email}) {
    return ConversationParticipant(
      userId: userId ?? this.userId,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
    );
  }
}

class Conversation {
  final String roomId;
  final String publicId;
  final ConversationParticipant participant;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime? lastMessageAt;

  Conversation({
    required this.roomId,
    required this.publicId,
    required this.participant,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
    this.lastMessageAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    try {
      final roomId = json['roomId'];
      if (roomId == null) {
        throw Exception('roomId is null in JSON: $json');
      }

      final publicId = json['publicId'];
      if (publicId == null) {
        throw Exception('publicId is null in JSON: $json');
      }

      final participant = json['participant'];
      if (participant == null) {
        throw Exception('participant is null in JSON: $json');
      }

      final createdAt = json['createdAt'];
      if (createdAt == null) {
        throw Exception('createdAt is null in JSON: $json');
      }

      return Conversation(
        roomId: roomId as String,
        publicId: publicId as String,
        participant: ConversationParticipant.fromJson(participant as Map<String, dynamic>),
        lastMessage: json['lastMessage'] != null ? Message.fromJson(json['lastMessage'] as Map<String, dynamic>) : null,
        unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(createdAt as String),
        lastMessageAt: json['lastMessageAt'] != null ? DateTime.parse(json['lastMessageAt'] as String) : null,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'publicId': publicId,
      'participant': participant.toJson(),
      if (lastMessage != null) 'lastMessage': lastMessage!.toJson(),
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
      if (lastMessageAt != null) 'lastMessageAt': lastMessageAt!.toIso8601String(),
    };
  }

  Conversation copyWith({
    String? roomId,
    String? publicId,
    ConversationParticipant? participant,
    Message? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? lastMessageAt,
  }) {
    return Conversation(
      roomId: roomId ?? this.roomId,
      publicId: publicId ?? this.publicId,
      participant: participant ?? this.participant,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }
}

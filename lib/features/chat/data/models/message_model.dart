class Message {
  final String id;
  final String roomId;
  final String senderId;
  final String senderProfileId;
  final String? senderName;
  final String? senderCompanyName;
  final String content;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderProfileId,
    this.senderName,
    this.senderCompanyName,
    required this.content,
    required this.createdAt,
    this.metadata,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    try {
      print('[Message] Parsing JSON: $json');
      
      final id = json['id'];
      if (id == null) {
        throw Exception('id is null in JSON: $json');
      }
      print('[Message] id: $id (type: ${id.runtimeType})');
      
      final roomId = json['roomId'];
      if (roomId == null) {
        throw Exception('roomId is null in JSON: $json');
      }
      print('[Message] roomId: $roomId (type: ${roomId.runtimeType})');
      
      final senderId = json['senderId'];
      if (senderId == null) {
        throw Exception('senderId is null in JSON: $json');
      }
      print('[Message] senderId: $senderId (type: ${senderId.runtimeType})');
      
      final senderProfileId = json['senderProfileId'];
      if (senderProfileId == null) {
        throw Exception('senderProfileId is null in JSON: $json');
      }
      print('[Message] senderProfileId: $senderProfileId (type: ${senderProfileId.runtimeType})');
      
      final content = json['content'];
      if (content == null) {
        throw Exception('content is null in JSON: $json');
      }
      print('[Message] content: $content (type: ${content.runtimeType})');
      
      final createdAt = json['createdAt'];
      if (createdAt == null) {
        throw Exception('createdAt is null in JSON: $json');
      }
      print('[Message] createdAt: $createdAt (type: ${createdAt.runtimeType})');
      
      return Message(
        id: id as String,
        roomId: roomId as String,
        senderId: senderId as String,
        senderProfileId: senderProfileId as String,
        senderName: json['senderName'] as String?,
        senderCompanyName: json['senderCompanyName'] as String?,
        content: content as String,
        createdAt: DateTime.parse(createdAt as String),
        metadata: json['metadata'] as Map<String, dynamic>?,
      );
    } catch (e, stackTrace) {
      print('[Message] ERROR parsing JSON: $e');
      print('[Message] JSON data: $json');
      print('[Message] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'senderProfileId': senderProfileId,
      if (senderName != null) 'senderName': senderName,
      if (senderCompanyName != null) 'senderCompanyName': senderCompanyName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  Message copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? senderProfileId,
    String? senderName,
    String? senderCompanyName,
    String? content,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderProfileId: senderProfileId ?? this.senderProfileId,
      senderName: senderName ?? this.senderName,
      senderCompanyName: senderCompanyName ?? this.senderCompanyName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  bool isFromCurrentUser(String currentUserId) => senderId == currentUserId;
}

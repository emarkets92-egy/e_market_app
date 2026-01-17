import 'message_model.dart';

class UnseenMessagesResponse {
  final List<Message> messages;
  final int totalUnread;
  final Map<String, int> unreadByRoom;

  UnseenMessagesResponse({required this.messages, required this.totalUnread, required this.unreadByRoom});

  factory UnseenMessagesResponse.fromJson(Map<String, dynamic> json) {
    try {
      final messagesList = json['messages'];
      if (messagesList == null) {
        throw Exception('messages is null in JSON: $json');
      }

      final messages = (messagesList as List<dynamic>).map((item) {
        try {
          return Message.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          rethrow;
        }
      }).toList();

      return UnseenMessagesResponse(
        messages: messages,
        totalUnread: (json['totalUnread'] as num?)?.toInt() ?? 0,
        unreadByRoom: json['unreadByRoom'] != null
            ? Map<String, int>.from((json['unreadByRoom'] as Map<String, dynamic>).map((key, value) => MapEntry(key, (value as num).toInt())))
            : <String, int>{},
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'messages': messages.map((e) => e.toJson()).toList(), 'totalUnread': totalUnread, 'unreadByRoom': unreadByRoom};
  }
}

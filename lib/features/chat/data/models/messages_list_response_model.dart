import 'message_model.dart';

class MessagesListResponse {
  final List<Message> messages;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  MessagesListResponse({required this.messages, required this.total, required this.page, required this.limit, required this.totalPages});

  factory MessagesListResponse.fromJson(Map<String, dynamic> json) {
    try {
      final messagesList = json['messages'];
      if (messagesList == null) {
        throw Exception('messages is null in JSON: $json');
      }
      final messages = (messagesList).map((item) {
        try {
          return Message.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          rethrow;
        }
      }).toList();

      return MessagesListResponse(
        messages: messages,
        total: (json['total'] as num?)?.toInt() ?? 0,
        page: (json['page'] as num?)?.toInt() ?? 1,
        limit: (json['limit'] as num?)?.toInt() ?? 50,
        totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'messages': messages.map((e) => e.toJson()).toList(), 'total': total, 'page': page, 'limit': limit, 'totalPages': totalPages};
  }
}

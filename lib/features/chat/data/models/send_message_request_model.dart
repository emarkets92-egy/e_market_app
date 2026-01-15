class SendMessageRequestModel {
  final String recipientProfileId;
  final String content;

  SendMessageRequestModel({
    required this.recipientProfileId,
    required this.content,
  }) {
    if (content.isEmpty || content.length > 5000) {
      throw ArgumentError('Content must be between 1 and 5000 characters');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'recipientProfileId': recipientProfileId,
      'content': content,
    };
  }
}

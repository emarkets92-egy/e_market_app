class StartChatRequestModel {
  final String recipientProfileId;

  StartChatRequestModel({required this.recipientProfileId});

  Map<String, dynamic> toJson() {
    return {
      'recipientProfileId': recipientProfileId,
    };
  }
}

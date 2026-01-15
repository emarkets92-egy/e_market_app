import 'conversation_model.dart';

class StartChatResponseModel {
  final String roomId;
  final String publicId;
  final bool created;
  final ConversationParticipant participant;

  StartChatResponseModel({required this.roomId, required this.publicId, required this.created, required this.participant});

  factory StartChatResponseModel.fromJson(Map<String, dynamic> json) {
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

      return StartChatResponseModel(
        roomId: roomId as String,
        publicId: publicId as String,
        created: json['created'] as bool? ?? false,
        participant: ConversationParticipant.fromJson(participant as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'roomId': roomId, 'publicId': publicId, 'created': created, 'participant': participant.toJson()};
  }
}

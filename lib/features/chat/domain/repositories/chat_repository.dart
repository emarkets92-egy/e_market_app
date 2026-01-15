import '../../data/models/message_model.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/unseen_messages_response_model.dart';
import '../../data/models/messages_list_response_model.dart';
import '../../data/models/search_profiles_response_model.dart';
import '../../data/models/start_chat_response_model.dart';

abstract class ChatRepository {
  Future<UnseenMessagesResponse> getUnseenMessages({int limit = 20});
  Future<List<Conversation>> getConversations();
  Future<MessagesListResponse> getMessages(String roomId, {int page = 1, int limit = 50});
  Future<Message> sendMessage(String recipientProfileId, String content);
  Future<int> markMessagesAsRead(String roomId, {List<String>? messageIds});
  Future<SearchProfilesResponseModel> searchUnlockedProfiles({
    String? query,
    int page = 1,
    int limit = 20,
    bool excludeExistingChats = false,
  });
  Future<StartChatResponseModel> startChat(String recipientProfileId);
}

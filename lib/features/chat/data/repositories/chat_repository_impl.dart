import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';
import '../models/unseen_messages_response_model.dart';
import '../models/messages_list_response_model.dart';
import '../models/search_profiles_response_model.dart';
import '../models/start_chat_response_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UnseenMessagesResponse> getUnseenMessages({int limit = 20}) async {
    try {
      return await remoteDataSource.getUnseenMessages(limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Conversation>> getConversations() async {
    try {
      return await remoteDataSource.getConversations();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MessagesListResponse> getMessages(String roomId, {int page = 1, int limit = 50}) async {
    try {
      return await remoteDataSource.getMessages(roomId, page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Message> sendMessage(String recipientProfileId, String content) async {
    try {
      return await remoteDataSource.sendMessage(recipientProfileId, content);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> markMessagesAsRead(String roomId, {List<String>? messageIds}) async {
    try {
      return await remoteDataSource.markMessagesAsRead(roomId, messageIds: messageIds);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SearchProfilesResponseModel> searchUnlockedProfiles({
    String? query,
    int page = 1,
    int limit = 20,
    bool excludeExistingChats = false,
  }) async {
    try {
      return await remoteDataSource.searchUnlockedProfiles(
        query: query,
        page: page,
        limit: limit,
        excludeExistingChats: excludeExistingChats,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<StartChatResponseModel> startChat(String recipientProfileId) async {
    try {
      return await remoteDataSource.startChat(recipientProfileId);
    } catch (e) {
      rethrow;
    }
  }
}

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';
import '../models/unseen_messages_response_model.dart';
import '../models/messages_list_response_model.dart';
import '../models/send_message_request_model.dart';
import '../models/mark_read_request_model.dart';
import '../models/search_profiles_response_model.dart';
import '../models/start_chat_request_model.dart';
import '../models/start_chat_response_model.dart';

abstract class ChatRemoteDataSource {
  Future<UnseenMessagesResponse> getUnseenMessages({int limit = 20});
  Future<List<Conversation>> getConversations();
  Future<MessagesListResponse> getMessages(String roomId, {int page = 1, int limit = 50});
  Future<Message> sendMessage(String recipientProfileId, String content);
  Future<int> markMessagesAsRead(String roomId, {List<String>? messageIds});
  Future<SearchProfilesResponseModel> searchUnlockedProfiles({String? query, int page = 1, int limit = 20, bool excludeExistingChats = false});
  Future<StartChatResponseModel> startChat(String recipientProfileId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UnseenMessagesResponse> getUnseenMessages({int limit = 20}) async {
    try {
      final response = await apiClient.get(Endpoints.chatUnseenMessages, queryParameters: {'limit': limit});
      return UnseenMessagesResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<Conversation>> getConversations() async {
    try {
      print('[ChatRemoteDataSource] getConversations called');
      final response = await apiClient.get(Endpoints.chatConversations);
      print('[ChatRemoteDataSource] getConversations response received: ${response.data}');
      final conversationsList = response.data as List<dynamic>;
      print('[ChatRemoteDataSource] getConversations list length: ${conversationsList.length}');
      return conversationsList.map((item) {
        try {
          return Conversation.fromJson(item as Map<String, dynamic>);
        } catch (e, stackTrace) {
          print('[ChatRemoteDataSource] getConversations ERROR parsing conversation item: $e');
          print('[ChatRemoteDataSource] Conversation item data: $item');
          print('[ChatRemoteDataSource] Stack trace: $stackTrace');
          rethrow;
        }
      }).toList();
    } on DioException catch (e) {
      print('[ChatRemoteDataSource] getConversations DioException: $e');
      print('[ChatRemoteDataSource] Response data: ${e.response?.data}');
      rethrow;
    } catch (e, stackTrace) {
      print('[ChatRemoteDataSource] getConversations ERROR: $e');
      print('[ChatRemoteDataSource] Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<MessagesListResponse> getMessages(String roomId, {int page = 1, int limit = 50}) async {
    try {
      final response = await apiClient.get(Endpoints.chatMessages(roomId), queryParameters: {'page': page, 'limit': limit});
      return MessagesListResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<Message> sendMessage(String recipientProfileId, String content) async {
    try {
      final request = SendMessageRequestModel(recipientProfileId: recipientProfileId, content: content);
      final response = await apiClient.post(Endpoints.chatSendMessage, data: request.toJson());
      return Message.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<int> markMessagesAsRead(String roomId, {List<String>? messageIds}) async {
    try {
      final request = MarkReadRequestModel(messageIds: messageIds);
      final response = await apiClient.post(Endpoints.chatMarkRead(roomId), data: request.toJson());
      return (response.data['marked'] as num).toInt();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<SearchProfilesResponseModel> searchUnlockedProfiles({String? query, int page = 1, int limit = 20, bool excludeExistingChats = false}) async {
    try {
      print('[ChatRemoteDataSource] searchUnlockedProfiles called with: query=$query, page=$page, limit=$limit, excludeExistingChats=$excludeExistingChats');
      final queryParameters = <String, dynamic>{'page': page, 'limit': limit, 'excludeExistingChats': excludeExistingChats};
      if (query != null && query.isNotEmpty) {
        queryParameters['query'] = query;
      }
      final response = await apiClient.get(Endpoints.chatSearchProfiles, queryParameters: queryParameters);
      print('[ChatRemoteDataSource] searchUnlockedProfiles response received: ${response.data}');
      return SearchProfilesResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('[ChatRemoteDataSource] searchUnlockedProfiles DioException: $e');
      print('[ChatRemoteDataSource] Response data: ${e.response?.data}');
      rethrow;
    } catch (e, stackTrace) {
      print('[ChatRemoteDataSource] searchUnlockedProfiles ERROR: $e');
      print('[ChatRemoteDataSource] Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<StartChatResponseModel> startChat(String recipientProfileId) async {
    try {
      final request = StartChatRequestModel(recipientProfileId: recipientProfileId);
      final response = await apiClient.post(Endpoints.chatStart, data: request.toJson());
      return StartChatResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }
}

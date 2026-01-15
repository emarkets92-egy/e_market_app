import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/chat_repository.dart';
import '../cubit/chat_state.dart';
import '../../data/models/message_model.dart';
import '../../data/models/start_chat_response_model.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;

  ChatCubit(this._repository) : super(const ChatState.initial());

  Future<void> loadConversations() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final conversations = await _repository.getConversations();
      // Sort by lastMessageAt (most recent first)
      conversations.sort((a, b) {
        final aTime = a.lastMessageAt ?? a.createdAt;
        final bTime = b.lastMessageAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      emit(state.copyWith(conversations: conversations, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadMessages(String roomId) async {
    emit(state.copyWith(isLoading: true, error: null, currentRoomId: roomId, currentPage: 1));
    try {
      final response = await _repository.getMessages(roomId, page: 1, limit: 50);
      emit(state.copyWith(
        currentMessages: response.messages,
        isLoading: false,
        currentPage: 1,
        hasMoreMessages: response.page < response.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadMoreMessages() async {
    if (!state.hasMoreMessages || state.isLoading) return;

    emit(state.copyWith(isLoading: true));
    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getMessages(state.currentRoomId!, page: nextPage, limit: 50);
      final updatedMessages = [...response.messages, ...state.currentMessages];
      emit(state.copyWith(
        currentMessages: updatedMessages,
        isLoading: false,
        currentPage: nextPage,
        hasMoreMessages: response.page < response.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> sendMessage(String recipientProfileId, String content) async {
    // Optimistic update
    final tempMessage = Message(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      roomId: state.currentRoomId ?? 'temp-room',
      senderId: 'current-user', // Will be replaced by actual response
      senderProfileId: 'current-profile',
      content: content,
      createdAt: DateTime.now(),
    );

    emit(state.copyWith(
      isSending: true,
      error: null,
      currentMessages: [...state.currentMessages, tempMessage],
    ));

    try {
      final sentMessage = await _repository.sendMessage(recipientProfileId, content);
      
      // Replace temp message with actual message
      final updatedMessages = state.currentMessages.map((msg) {
        if (msg.id == tempMessage.id) {
          return sentMessage;
        }
        return msg;
      }).toList();

      // Update current room ID if it was null
      final roomId = state.currentRoomId ?? sentMessage.roomId;

      emit(state.copyWith(
        isSending: false,
        currentMessages: updatedMessages,
        currentRoomId: roomId,
      ));

      // Refresh conversations to update last message
      await loadConversations();
    } catch (e) {
      // Remove temp message on error
      final updatedMessages = state.currentMessages.where((msg) => msg.id != tempMessage.id).toList();
      emit(state.copyWith(
        isSending: false,
        error: e.toString(),
        currentMessages: updatedMessages,
      ));
    }
  }

  Future<void> markMessagesAsRead(String roomId) async {
    try {
      await _repository.markMessagesAsRead(roomId);
      // Update unread count for this room
      final updatedUnreadByRoom = Map<String, int>.from(state.unreadByRoom);
      updatedUnreadByRoom[roomId] = 0;
      
      // Update conversation unread count
      final updatedConversations = state.conversations.map((conv) {
        if (conv.roomId == roomId) {
          return conv.copyWith(unreadCount: 0);
        }
        return conv;
      }).toList();

      // Recalculate total unread
      final newTotalUnread = updatedUnreadByRoom.values.fold(0, (sum, count) => sum + count);

      emit(state.copyWith(
        unreadByRoom: updatedUnreadByRoom,
        conversations: updatedConversations,
        totalUnread: newTotalUnread,
      ));
    } catch (e) {
      // Silently fail - don't show error for read receipts
    }
  }

  Future<void> getUnseenMessages() async {
    try {
      final response = await _repository.getUnseenMessages(limit: 20);
      emit(state.copyWith(
        totalUnread: response.totalUnread,
        unreadByRoom: response.unreadByRoom,
      ));
    } catch (e) {
      // Silently fail - don't show error for badge updates
    }
  }

  Future<void> refreshConversations() async {
    await loadConversations();
    await getUnseenMessages();
  }

  Future<void> refreshMessages() async {
    if (state.currentRoomId != null) {
      await loadMessages(state.currentRoomId!);
    }
  }

  void startPolling() {
    emit(state.copyWith(isPolling: true));
  }

  void stopPolling() {
    emit(state.copyWith(isPolling: false));
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  Future<void> searchUnlockedProfiles({
    String? query,
    int page = 1,
    int limit = 20,
    bool excludeExistingChats = false,
    bool append = false,
  }) async {
    emit(state.copyWith(
      isLoadingUnlockedProfiles: true,
      error: null,
      searchQuery: query,
    ));
    try {
      final response = await _repository.searchUnlockedProfiles(
        query: query,
        page: page,
        limit: limit,
        excludeExistingChats: excludeExistingChats,
      );
      final updatedProfiles = append
          ? [...state.unlockedProfiles, ...response.profiles]
          : response.profiles;
      emit(state.copyWith(
        unlockedProfiles: updatedProfiles,
        isLoadingUnlockedProfiles: false,
        unlockedProfilesPage: response.page,
        unlockedProfilesTotalPages: response.totalPages,
        hasMoreUnlockedProfiles: response.page < response.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingUnlockedProfiles: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> loadMoreUnlockedProfiles({
    bool excludeExistingChats = false,
  }) async {
    if (!state.hasMoreUnlockedProfiles || state.isLoadingUnlockedProfiles) return;

    final nextPage = state.unlockedProfilesPage + 1;
    await searchUnlockedProfiles(
      query: state.searchQuery,
      page: nextPage,
      excludeExistingChats: excludeExistingChats,
      append: true,
    );
  }

  Future<StartChatResponseModel?> startChat(String recipientProfileId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await _repository.startChat(recipientProfileId);
      
      // If room was created, refresh conversations to include it
      if (response.created) {
        await loadConversations();
      }
      
      emit(state.copyWith(
        isLoading: false,
        currentRoomId: response.roomId,
      ));
      
      return response;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
      return null;
    }
  }

  void clearUnlockedProfiles() {
    emit(state.copyWith(
      unlockedProfiles: const [],
      searchQuery: null,
      unlockedProfilesPage: 1,
      unlockedProfilesTotalPages: 1,
      hasMoreUnlockedProfiles: false,
    ));
  }
}

import '../../data/models/message_model.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/unlocked_profile_model.dart';

class ChatState {
  final List<Conversation> conversations;
  final List<Message> currentMessages;
  final String? currentRoomId;
  final bool isLoading;
  final bool isSending;
  final String? error;
  final int totalUnread;
  final Map<String, int> unreadByRoom;
  final int currentPage;
  final bool hasMoreMessages;
  final bool isPolling;
  final List<UnlockedProfileModel> unlockedProfiles;
  final bool isLoadingUnlockedProfiles;
  final String? searchQuery;
  final int unlockedProfilesPage;
  final int unlockedProfilesTotalPages;
  final bool hasMoreUnlockedProfiles;

  const ChatState({
    this.conversations = const [],
    this.currentMessages = const [],
    this.currentRoomId,
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.totalUnread = 0,
    this.unreadByRoom = const {},
    this.currentPage = 1,
    this.hasMoreMessages = true,
    this.isPolling = false,
    this.unlockedProfiles = const [],
    this.isLoadingUnlockedProfiles = false,
    this.searchQuery,
    this.unlockedProfilesPage = 1,
    this.unlockedProfilesTotalPages = 1,
    this.hasMoreUnlockedProfiles = false,
  });

  const ChatState.initial()
    : conversations = const [],
      currentMessages = const [],
      currentRoomId = null,
      isLoading = false,
      isSending = false,
      error = null,
      totalUnread = 0,
      unreadByRoom = const {},
      currentPage = 1,
      hasMoreMessages = true,
      isPolling = false,
      unlockedProfiles = const [],
      isLoadingUnlockedProfiles = false,
      searchQuery = null,
      unlockedProfilesPage = 1,
      unlockedProfilesTotalPages = 1,
      hasMoreUnlockedProfiles = false;

  ChatState copyWith({
    List<Conversation>? conversations,
    List<Message>? currentMessages,
    String? currentRoomId,
    bool? isLoading,
    bool? isSending,
    String? error,
    int? totalUnread,
    Map<String, int>? unreadByRoom,
    int? currentPage,
    bool? hasMoreMessages,
    bool? isPolling,
    List<UnlockedProfileModel>? unlockedProfiles,
    bool? isLoadingUnlockedProfiles,
    String? searchQuery,
    int? unlockedProfilesPage,
    int? unlockedProfilesTotalPages,
    bool? hasMoreUnlockedProfiles,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      currentMessages: currentMessages ?? this.currentMessages,
      currentRoomId: currentRoomId ?? this.currentRoomId,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error ?? this.error,
      totalUnread: totalUnread ?? this.totalUnread,
      unreadByRoom: unreadByRoom ?? this.unreadByRoom,
      currentPage: currentPage ?? this.currentPage,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      isPolling: isPolling ?? this.isPolling,
      unlockedProfiles: unlockedProfiles ?? this.unlockedProfiles,
      isLoadingUnlockedProfiles: isLoadingUnlockedProfiles ?? this.isLoadingUnlockedProfiles,
      searchQuery: searchQuery ?? this.searchQuery,
      unlockedProfilesPage: unlockedProfilesPage ?? this.unlockedProfilesPage,
      unlockedProfilesTotalPages: unlockedProfilesTotalPages ?? this.unlockedProfilesTotalPages,
      hasMoreUnlockedProfiles: hasMoreUnlockedProfiles ?? this.hasMoreUnlockedProfiles,
    );
  }
}

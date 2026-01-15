import 'dart:async';
import '../cubit/chat_cubit.dart';

class ChatPollingService {
  final ChatCubit chatCubit;
  Timer? _conversationsTimer;
  Timer? _messagesTimer;
  String? _currentRoomId;

  ChatPollingService(this.chatCubit);

  void startConversationsPolling() {
    stopPolling();
    _conversationsTimer = Timer.periodic(const Duration(seconds: 45), (timer) {
      if (chatCubit.state.isPolling) {
        chatCubit.refreshConversations();
      } else {
        timer.cancel();
      }
    });
  }

  void startMessagesPolling(String roomId) {
    _currentRoomId = roomId;
    _messagesTimer?.cancel();
    _messagesTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
      if (chatCubit.state.isPolling && chatCubit.state.currentRoomId == roomId) {
        chatCubit.refreshMessages();
      } else {
        timer.cancel();
      }
    });
  }

  void stopPolling() {
    _conversationsTimer?.cancel();
    _conversationsTimer = null;
    _messagesTimer?.cancel();
    _messagesTimer = null;
    _currentRoomId = null;
  }

  void dispose() {
    stopPolling();
  }
}

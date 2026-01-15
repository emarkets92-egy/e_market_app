import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_field.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../services/chat_polling_service.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class ChatScreen extends StatefulWidget {
  final String? roomId;
  final String? recipientProfileId;

  const ChatScreen({
    super.key,
    this.roomId,
    this.recipientProfileId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();
  late final ChatPollingService _pollingService;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _pollingService = di.sl<ChatPollingService>();
    final chatCubit = di.sl<ChatCubit>();
    final authCubit = di.sl<AuthCubit>();
    _currentUserId = authCubit.state.user?.id;

    if (widget.roomId != null) {
      chatCubit.loadMessages(widget.roomId!);
      chatCubit.markMessagesAsRead(widget.roomId!);
      chatCubit.startPolling();
      _pollingService.startMessagesPolling(widget.roomId!);
    } else if (widget.recipientProfileId != null) {
      // New conversation - start chat to create/get room
      chatCubit.startChat(widget.recipientProfileId!).then((response) {
        if (response != null && mounted) {
          // Room is ready, load messages if any exist
          chatCubit.loadMessages(response.roomId);
          chatCubit.markMessagesAsRead(response.roomId);
          chatCubit.startPolling();
          _pollingService.startMessagesPolling(response.roomId);
        } else {
          // Room creation failed, but still allow user to try sending a message
          chatCubit.startPolling();
        }
      });
    }

    // Auto-scroll to bottom when new messages arrive
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // User is at bottom, can auto-scroll
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    di.sl<ChatCubit>().stopPolling();
    _pollingService.stopPolling();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final chatCubit = di.sl<ChatCubit>();
    if (chatCubit.state.currentRoomId != null) {
      await chatCubit.refreshMessages();
    }
    _refreshController.refreshCompleted();
  }

  void _handleSend(String content) {
    final chatCubit = di.sl<ChatCubit>();
    if (widget.recipientProfileId != null) {
      // If we don't have a roomId yet, start chat first
      if (chatCubit.state.currentRoomId == null) {
        chatCubit.startChat(widget.recipientProfileId!).then((response) {
          if (response != null) {
            // Room is ready, now send the message
            chatCubit.sendMessage(widget.recipientProfileId!, content).then((_) {
              // After sending, load messages and start polling
              chatCubit.loadMessages(response.roomId);
              _pollingService.startMessagesPolling(response.roomId);
            });
          }
        });
      } else {
        // Room already exists, just send the message
        chatCubit.sendMessage(widget.recipientProfileId!, content).then((_) {
          // After sending, if we got a roomId, load messages and start polling
          if (chatCubit.state.currentRoomId != null && chatCubit.state.currentRoomId != widget.roomId) {
            chatCubit.loadMessages(chatCubit.state.currentRoomId!);
            _pollingService.startMessagesPolling(chatCubit.state.currentRoomId!);
          }
        });
      }
    } else if (chatCubit.state.currentRoomId != null) {
      // Find the conversation to get recipient profile ID
      try {
        final conversation = chatCubit.state.conversations.firstWhere(
          (conv) => conv.roomId == chatCubit.state.currentRoomId,
        );
        chatCubit.sendMessage(conversation.participant.profileId, content);
      } catch (e) {
        // Conversation not found, show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to send message. Conversation not found.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getParticipantName() {
    final chatCubit = di.sl<ChatCubit>();
    if (widget.roomId != null) {
      try {
        final conversation = chatCubit.state.conversations.firstWhere(
          (conv) => conv.roomId == widget.roomId,
        );
        return conversation.participant.name ??
            conversation.participant.companyName ??
            conversation.participant.email;
      } catch (e) {
        // Conversation not found in list yet, return generic name
        return 'chat'.tr();
      }
    } else if (widget.recipientProfileId != null) {
      // For new conversations, we might have participant info from startChat response
      // For now, return a generic name - could be enhanced to store participant info in state
      return 'new_chat'.tr();
    }
    return 'chat'.tr();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_getParticipantName()),
        elevation: 0,
      ),
      body: BlocListener<ChatCubit, ChatState>(
        bloc: di.sl<ChatCubit>(),
        listener: (context, state) {
          // Auto-scroll when new messages arrive
          if (state.currentMessages.isNotEmpty) {
            _scrollToBottom();
          }
          // Mark as read when messages are loaded
          if (state.currentRoomId != null && state.currentMessages.isNotEmpty && !state.isLoading) {
            di.sl<ChatCubit>().markMessagesAsRead(state.currentRoomId!);
          }
        },
        child: BlocBuilder<ChatCubit, ChatState>(
          bloc: di.sl<ChatCubit>(),
          builder: (context, state) {
            // Handle loading state
            if (state.isLoading && state.currentMessages.isEmpty) {
              return const LoadingIndicator();
            }

            // Handle error state
            if (state.error != null && state.currentMessages.isEmpty) {
              return AppErrorWidget(
                message: state.error!,
                onRetry: () {
                  di.sl<ChatCubit>().clearError();
                  if (widget.roomId != null) {
                    di.sl<ChatCubit>().loadMessages(widget.roomId!);
                  }
                },
              );
            }

            // Check if we need to load messages for a room
            if (widget.roomId != null && state.currentRoomId != widget.roomId) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                di.sl<ChatCubit>().loadMessages(widget.roomId!);
              });
            }

            final messages = state.currentMessages;
            final hasMoreMessages = state.hasMoreMessages;

            return Column(
              children: [
                // Messages list
                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'no_messages_yet'.tr(),
                                style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'send_first_message'.tr(),
                                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                      : SmartRefresher(
                          controller: _refreshController,
                          onRefresh: _onRefresh,
                          enablePullDown: true,
                          enablePullUp: hasMoreMessages,
                          onLoading: () async {
                            await di.sl<ChatCubit>().loadMoreMessages();
                            _refreshController.loadComplete();
                          },
                          header: const WaterDropMaterialHeader(),
                          footer: CustomFooter(
                            builder: (context, mode) {
                              if (mode == LoadStatus.loading) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          child: ListView.builder(
                            controller: _scrollController,
                            reverse: false,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isFromCurrentUser = _currentUserId != null && message.isFromCurrentUser(_currentUserId!);
                              final showTimestamp = index == 0 ||
                                  index == messages.length - 1 ||
                                  messages[index].createdAt.difference(messages[index - 1].createdAt).inMinutes > 1;

                              return MessageBubble(
                                message: message,
                                isFromCurrentUser: isFromCurrentUser,
                                showTimestamp: showTimestamp,
                                currentUserId: _currentUserId,
                              );
                            },
                          ),
                        ),
                ),
                // Input field
                MessageInputField(
                  onSend: _handleSend,
                  isSending: state.isSending,
                  error: state.error,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/conversation_item.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../services/chat_polling_service.dart';
import '../../../home/presentation/widgets/sidebar_navigation.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  State<ConversationsListScreen> createState() => _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  late final ChatPollingService _pollingService;

  @override
  void initState() {
    super.initState();
    _pollingService = di.sl<ChatPollingService>();
    final chatCubit = di.sl<ChatCubit>();
    chatCubit.loadConversations();
    chatCubit.getUnseenMessages();
    chatCubit.startPolling();
    _pollingService.startConversationsPolling();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    di.sl<ChatCubit>().stopPolling();
    _pollingService.stopPolling();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final chatCubit = di.sl<ChatCubit>();
    await chatCubit.refreshConversations();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          const SidebarNavigation(),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Text('messages'.tr()),
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'start_new_chat'.tr(),
                      onPressed: () {
                        context.push(RouteNames.searchUnlockedProfiles);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: BlocBuilder<ChatCubit, ChatState>(
                    bloc: di.sl<ChatCubit>(),
                    builder: (context, state) {
                      if (state.isLoading && state.conversations.isEmpty) {
                        return const LoadingIndicator();
                      }

                      if (state.error != null && state.conversations.isEmpty) {
                        return AppErrorWidget(
                          message: state.error!,
                          onRetry: () {
                            di.sl<ChatCubit>().clearError();
                            di.sl<ChatCubit>().loadConversations();
                          },
                        );
                      }

                      if (state.conversations.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'no_conversations_yet'.tr(),
                                style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text('start_chatting_with_unlocked_profiles'.tr(), style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                            ],
                          ),
                        );
                      }

                      return SmartRefresher(
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        enablePullDown: true,
                        header: const WaterDropMaterialHeader(),
                        child: ListView.builder(
                          itemCount: state.conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = state.conversations[index];
                            return ConversationItem(
                              conversation: conversation,
                              onTap: () {
                                context.push(RouteNames.chatWithRoomId(conversation.roomId));
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/unlocked_profile_item.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../home/presentation/widgets/sidebar_navigation.dart';

class SearchUnlockedProfilesScreen extends StatefulWidget {
  const SearchUnlockedProfilesScreen({super.key});

  @override
  State<SearchUnlockedProfilesScreen> createState() => _SearchUnlockedProfilesScreenState();
}

class _SearchUnlockedProfilesScreenState extends State<SearchUnlockedProfilesScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _excludeExistingChats = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final chatCubit = di.sl<ChatCubit>();
    // Load initial profiles
    chatCubit.searchUnlockedProfiles(excludeExistingChats: _excludeExistingChats);

    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _refreshController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final chatCubit = di.sl<ChatCubit>();
      chatCubit.searchUnlockedProfiles(
        query: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        excludeExistingChats: _excludeExistingChats,
      );
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      final chatCubit = di.sl<ChatCubit>();
      if (chatCubit.state.hasMoreUnlockedProfiles && !chatCubit.state.isLoadingUnlockedProfiles) {
        chatCubit.loadMoreUnlockedProfiles(excludeExistingChats: _excludeExistingChats);
      }
    }
  }

  Future<void> _onRefresh() async {
    final chatCubit = di.sl<ChatCubit>();
    await chatCubit.searchUnlockedProfiles(
      query: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      excludeExistingChats: _excludeExistingChats,
    );
    _refreshController.refreshCompleted();
  }

  void _toggleExcludeExistingChats(bool value) {
    setState(() {
      _excludeExistingChats = value;
    });
    final chatCubit = di.sl<ChatCubit>();
    chatCubit.searchUnlockedProfiles(
      query: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      excludeExistingChats: _excludeExistingChats,
    );
  }

  Future<void> _handleStartChat(String profileId, String? existingRoomId) async {
    final chatCubit = di.sl<ChatCubit>();

    if (existingRoomId != null) {
      // Navigate to existing chat
      if (mounted) {
        context.push(RouteNames.chatWithRoomId(existingRoomId));
      }
    } else {
      // Start new chat
      final response = await chatCubit.startChat(profileId);
      if (response != null && mounted) {
        // Navigate to chat screen
        context.push(RouteNames.chatWithRoomId(response.roomId));
      } else if (mounted) {
        // Show error if chat creation failed
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('failed_to_start_chat'.tr()), backgroundColor: Colors.red));
      }
    }
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
                AppBar(title: Text('start_new_chat'.tr()), elevation: 0, automaticallyImplyLeading: false),
                // Search bar and filter
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Column(
                    children: [
                      // Search field
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'search_by_name_or_company'.tr(),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Filter checkbox
                      Row(
                        children: [
                          Checkbox(value: _excludeExistingChats, onChanged: (value) => _toggleExcludeExistingChats(value ?? false)),
                          Text('exclude_profiles_with_existing_conversations'.tr(), style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Profiles list
                Expanded(
                  child: BlocBuilder<ChatCubit, ChatState>(
                    bloc: di.sl<ChatCubit>(),
                    builder: (context, state) {
                      if (state.isLoadingUnlockedProfiles && state.unlockedProfiles.isEmpty) {
                        return const LoadingIndicator();
                      }

                      if (state.error != null && state.unlockedProfiles.isEmpty) {
                        return AppErrorWidget(
                          message: state.error!,
                          onRetry: () {
                            di.sl<ChatCubit>().clearError();
                            di.sl<ChatCubit>().searchUnlockedProfiles(
                              query: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
                              excludeExistingChats: _excludeExistingChats,
                            );
                          },
                        );
                      }

                      if (state.unlockedProfiles.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'no_unlocked_profiles_found'.tr(),
                                style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchController.text.isNotEmpty ? 'try_different_search_term'.tr() : 'unlock_profiles_to_start_chatting'.tr(),
                                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                              ),
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
                          controller: _scrollController,
                          itemCount: state.unlockedProfiles.length + (state.hasMoreUnlockedProfiles ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.unlockedProfiles.length) {
                              // Loading indicator for pagination
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            final profile = state.unlockedProfiles[index];
                            return UnlockedProfileItem(profile: profile, onTap: () => _handleStartChat(profile.profileId, profile.roomId));
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

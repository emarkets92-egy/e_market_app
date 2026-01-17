import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/theme.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../../../home/presentation/widgets/sidebar_navigation.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../widgets/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();
  bool? _readFilter;

  @override
  void initState() {
    super.initState();
    final notificationCubit = di.sl<NotificationCubit>();
    notificationCubit.loadNotifications();
    notificationCubit.getUnreadCount();
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      final state = di.sl<NotificationCubit>().state;
      if (state.hasMore && !state.isLoading) {
        di.sl<NotificationCubit>().loadMoreNotifications();
      }
    }
  }

  Future<void> _onRefresh() async {
    final notificationCubit = di.sl<NotificationCubit>();
    await notificationCubit.refreshNotifications();
    await notificationCubit.getUnreadCount();
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
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey, width: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'notifications'.tr(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const Spacer(),
                      // Filter buttons
                      _FilterChip(
                        label: 'all'.tr(),
                        isSelected: _readFilter == null,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _readFilter = null);
                            di.sl<NotificationCubit>().filterByRead(null);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'unread'.tr(),
                        isSelected: _readFilter == false,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _readFilter = false);
                            di.sl<NotificationCubit>().filterByRead(false);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      BlocBuilder<NotificationCubit, NotificationState>(
                        bloc: di.sl<NotificationCubit>(),
                        builder: (context, state) {
                          if (state.unreadCount > 0) {
                            return TextButton.icon(
                              onPressed: () async {
                                await di.sl<NotificationCubit>().markAllAsRead();
                                await di.sl<NotificationCubit>().getUnreadCount();
                              },
                              icon: const Icon(Icons.done_all, size: 18),
                              label: Text('mark_all_read'.tr()),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primaryBlue,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
                // Notifications List
                Expanded(
                  child: BlocBuilder<NotificationCubit, NotificationState>(
                    bloc: di.sl<NotificationCubit>(),
                    builder: (context, state) {
                      if (state.isLoading && state.notifications.isEmpty) {
                        return const LoadingIndicator();
                      }

                      if (state.error != null && state.notifications.isEmpty) {
                        return AppErrorWidget(
                          message: state.error!,
                          onRetry: () {
                            di.sl<NotificationCubit>().clearError();
                            di.sl<NotificationCubit>().loadNotifications();
                          },
                        );
                      }

                      if (state.notifications.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'no_notifications'.tr(),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'you_will_see_notifications_here'.tr(),
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
                          padding: const EdgeInsets.all(8),
                          itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.notifications.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final notification = state.notifications[index];
                            return NotificationItem(
                              notification: notification,
                              onTap: () async {
                                if (!notification.read) {
                                  await di.sl<NotificationCubit>().markAsRead(notification.id);
                                  await di.sl<NotificationCubit>().getUnreadCount();
                                }
                              },
                              onDelete: () async {
                                await di.sl<NotificationCubit>().deleteNotification(notification.id);
                                await di.sl<NotificationCubit>().getUnreadCount();
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppTheme.lightBlue,
      checkmarkColor: AppTheme.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryBlue : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notification_repository.dart';
import '../cubit/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super(const NotificationState.initial());

  Future<void> loadNotifications({
    int page = 1,
    int limit = 20,
    bool? read,
    String? type,
    bool append = false,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final response = await _repository.getNotifications(
        page: page,
        limit: limit,
        read: read,
        type: type,
      );

      final updatedNotifications = append
          ? [...state.notifications, ...response.data]
          : response.data;

      emit(state.copyWith(
        notifications: updatedNotifications,
        isLoading: false,
        currentPage: response.meta.page,
        totalPages: response.meta.totalPages,
        hasMore: response.meta.page < response.meta.totalPages,
        unreadCount: response.meta.unreadCount,
        readFilter: read,
        typeFilter: type,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadMoreNotifications() async {
    if (!state.hasMore || state.isLoading) return;

    final nextPage = state.currentPage + 1;
    await loadNotifications(
      page: nextPage,
      read: state.readFilter,
      type: state.typeFilter,
      append: true,
    );
  }

  Future<void> refreshNotifications() async {
    await loadNotifications(
      page: 1,
      read: state.readFilter,
      type: state.typeFilter,
      append: false,
    );
  }

  Future<void> getUnreadCount() async {
    try {
      final response = await _repository.getUnreadCount();
      emit(state.copyWith(unreadCount: response.count));
    } catch (e) {
      // Silently fail - don't show error for badge updates
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markNotificationAsRead(id);
      
      // Update local state
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == id) {
          return notification.copyWith(read: true, readAt: DateTime.now());
        }
        return notification;
      }).toList();

      // Update unread count
      final newUnreadCount = state.unreadCount > 0 ? state.unreadCount - 1 : 0;

      emit(state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _repository.markAllNotificationsAsRead();
      emit(state.copyWith(unreadCount: response.count));

      // Update all notifications to read
      final updatedNotifications = state.notifications.map((notification) {
        return notification.copyWith(read: true, readAt: DateTime.now());
      }).toList();

      emit(state.copyWith(notifications: updatedNotifications));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);
      
      // Remove from local state
      final updatedNotifications = state.notifications.where((n) => n.id != id).toList();
      
      // Update unread count if the deleted notification was unread
      final deletedNotification = state.notifications.firstWhere((n) => n.id == id);
      final newUnreadCount = deletedNotification.read
          ? state.unreadCount
          : (state.unreadCount > 0 ? state.unreadCount - 1 : 0);

      emit(state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteMultipleNotifications(List<String> ids) async {
    try {
      await _repository.deleteMultipleNotifications(ids);
      
      // Remove from local state
      final updatedNotifications = state.notifications.where((n) => !ids.contains(n.id)).toList();
      
      // Update unread count
      final deletedUnreadCount = state.notifications
          .where((n) => ids.contains(n.id) && !n.read)
          .length;
      final newUnreadCount = state.unreadCount > deletedUnreadCount
          ? state.unreadCount - deletedUnreadCount
          : 0;

      emit(state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void filterByRead(bool? read) {
    loadNotifications(page: 1, read: read, type: state.typeFilter, append: false);
  }

  void filterByType(String? type) {
    loadNotifications(page: 1, read: state.readFilter, type: type, append: false);
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}

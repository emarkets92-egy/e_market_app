import '../../data/models/notification_model.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final bool? readFilter;
  final String? typeFilter;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = false,
    this.readFilter,
    this.typeFilter,
  });

  const NotificationState.initial()
      : notifications = const [],
        unreadCount = 0,
        isLoading = false,
        error = null,
        currentPage = 1,
        totalPages = 1,
        hasMore = false,
        readFilter = null,
        typeFilter = null;

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool? readFilter,
    String? typeFilter,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      readFilter: readFilter ?? this.readFilter,
      typeFilter: typeFilter ?? this.typeFilter,
    );
  }
}

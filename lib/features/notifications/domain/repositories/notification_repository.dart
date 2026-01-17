import '../../data/models/notification_model.dart';
import '../../data/models/notification_list_response_model.dart';
import '../../data/models/unread_count_response_model.dart';
import '../../data/models/delete_response_model.dart';

abstract class NotificationRepository {
  Future<NotificationListResponseModel> getNotifications({
    int page = 1,
    int limit = 20,
    bool? read,
    String? type,
  });
  Future<UnreadCountResponseModel> getUnreadCount();
  Future<NotificationModel> getNotificationById(String id);
  Future<NotificationModel> markNotificationAsRead(String id);
  Future<UnreadCountResponseModel> markAllNotificationsAsRead();
  Future<DeleteResponseModel> deleteNotification(String id);
  Future<DeleteResponseModel> deleteMultipleNotifications(List<String> ids);
}

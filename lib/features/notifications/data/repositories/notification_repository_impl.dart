import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';
import '../models/notification_list_response_model.dart';
import '../models/unread_count_response_model.dart';
import '../models/delete_response_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<NotificationListResponseModel> getNotifications({
    int page = 1,
    int limit = 20,
    bool? read,
    String? type,
  }) async {
    try {
      return await remoteDataSource.getNotifications(
        page: page,
        limit: limit,
        read: read,
        type: type,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UnreadCountResponseModel> getUnreadCount() async {
    try {
      return await remoteDataSource.getUnreadCount();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<NotificationModel> getNotificationById(String id) async {
    try {
      return await remoteDataSource.getNotificationById(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<NotificationModel> markNotificationAsRead(String id) async {
    try {
      return await remoteDataSource.markNotificationAsRead(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UnreadCountResponseModel> markAllNotificationsAsRead() async {
    try {
      return await remoteDataSource.markAllNotificationsAsRead();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DeleteResponseModel> deleteNotification(String id) async {
    try {
      return await remoteDataSource.deleteNotification(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DeleteResponseModel> deleteMultipleNotifications(List<String> ids) async {
    try {
      return await remoteDataSource.deleteMultipleNotifications(ids);
    } catch (e) {
      rethrow;
    }
  }
}

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/notification_model.dart';
import '../models/notification_list_response_model.dart';
import '../models/unread_count_response_model.dart';
import '../models/delete_response_model.dart';

abstract class NotificationRemoteDataSource {
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

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<NotificationListResponseModel> getNotifications({
    int page = 1,
    int limit = 20,
    bool? read,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (read != null) {
        queryParams['read'] = read;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      final response = await apiClient.get(
        Endpoints.notifications,
        queryParameters: queryParams,
      );
      return NotificationListResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<UnreadCountResponseModel> getUnreadCount() async {
    try {
      final response = await apiClient.get(Endpoints.notificationsUnreadCount);
      return UnreadCountResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<NotificationModel> getNotificationById(String id) async {
    try {
      final response = await apiClient.get(Endpoints.notificationById(id));
      return NotificationModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<NotificationModel> markNotificationAsRead(String id) async {
    try {
      final response = await apiClient.patch(Endpoints.notificationMarkRead(id));
      return NotificationModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<UnreadCountResponseModel> markAllNotificationsAsRead() async {
    try {
      final response = await apiClient.patch(Endpoints.notificationsMarkAllRead);
      return UnreadCountResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<DeleteResponseModel> deleteNotification(String id) async {
    try {
      final response = await apiClient.delete(Endpoints.notificationById(id));
      return DeleteResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<DeleteResponseModel> deleteMultipleNotifications(List<String> ids) async {
    try {
      final queryParams = <String, dynamic>{
        'ids': ids.join(','),
      };
      final response = await apiClient.delete(
        Endpoints.notifications,
        queryParameters: queryParams,
      );
      return DeleteResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }
}

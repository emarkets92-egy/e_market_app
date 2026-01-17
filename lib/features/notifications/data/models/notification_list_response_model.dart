import 'notification_model.dart';

class NotificationListResponseModel {
  final List<NotificationModel> data;
  final NotificationMetaModel meta;

  NotificationListResponseModel({required this.data, required this.meta});

  factory NotificationListResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationListResponseModel(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      meta: NotificationMetaModel.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}

class NotificationMetaModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final int unreadCount;

  NotificationMetaModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.unreadCount,
  });

  factory NotificationMetaModel.fromJson(Map<String, dynamic> json) {
    return NotificationMetaModel(
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      unreadCount: (json['unreadCount'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
      'unreadCount': unreadCount,
    };
  }
}

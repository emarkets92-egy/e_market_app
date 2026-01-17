class DeleteResponseModel {
  final String? message;
  final int? count;

  DeleteResponseModel({this.message, this.count});

  factory DeleteResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteResponseModel(
      message: json['message'] as String?,
      count: json['count'] != null ? (json['count'] as num).toInt() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (message != null) 'message': message,
      if (count != null) 'count': count,
    };
  }
}

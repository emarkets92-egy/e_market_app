class UnreadCountResponseModel {
  final int count;

  UnreadCountResponseModel({required this.count});

  factory UnreadCountResponseModel.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponseModel(
      count: (json['count'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'count': count};
  }
}

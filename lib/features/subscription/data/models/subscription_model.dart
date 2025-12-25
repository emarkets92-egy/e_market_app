class SubscriptionModel {
  final String id;
  final String productId;
  final String productName;

  SubscriptionModel({
    required this.id,
    required this.productId,
    required this.productName,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'productId': productId, 'productName': productName};
  }
}

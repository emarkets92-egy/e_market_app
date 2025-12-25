class ExploreMarketRequestModel {
  final String productId;
  final String marketType;
  final int countryId;

  ExploreMarketRequestModel({
    required this.productId,
    required this.marketType,
    required this.countryId,
  });

  factory ExploreMarketRequestModel.fromJson(Map<String, dynamic> json) {
    return ExploreMarketRequestModel(
      productId: json['productId'] as String,
      marketType: json['marketType'] as String,
      countryId: (json['countryId'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'marketType': marketType,
      'countryId': countryId,
    };
  }
}

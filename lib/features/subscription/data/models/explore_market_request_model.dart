class ExploreMarketRequestModel {
  final String productId;
  final String marketType;
  final int countryId;
  final int? unseenPage;
  final int? unseenLimit;
  final int? seenPage;
  final int? seenLimit;

  ExploreMarketRequestModel({
    required this.productId,
    required this.marketType,
    required this.countryId,
    this.unseenPage,
    this.unseenLimit,
    this.seenPage,
    this.seenLimit,
  });

  factory ExploreMarketRequestModel.fromJson(Map<String, dynamic> json) {
    return ExploreMarketRequestModel(
      productId: json['productId'] as String,
      marketType: json['marketType'] as String,
      countryId: (json['countryId'] as num).toInt(),
      unseenPage: json['unseenPage'] != null ? (json['unseenPage'] as num).toInt() : null,
      unseenLimit: json['unseenLimit'] != null ? (json['unseenLimit'] as num).toInt() : null,
      seenPage: json['seenPage'] != null ? (json['seenPage'] as num).toInt() : null,
      seenLimit: json['seenLimit'] != null ? (json['seenLimit'] as num).toInt() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'marketType': marketType,
      'countryId': countryId,
      'unseenPage': unseenPage ?? 1, // Always include with default
      'unseenLimit': unseenLimit ?? 10, // Always include with default
      'seenPage': seenPage ?? 1, // Always include with default
      'seenLimit': seenLimit ?? 10, // Always include with default
    };
  }
}

class ExploreMarketRequestModel {
  final String productId;
  final String marketType;
  final int countryId;
  final int? unseenPage;
  final int? unseenLimit;
  final int? seenPage;
  final int? seenLimit;
  // Deprecated: kept for backward compatibility
  @Deprecated('Use unseenPage and seenPage instead')
  final int? page;
  @Deprecated('Use unseenLimit and seenLimit instead')
  final int? limit;

  ExploreMarketRequestModel({
    required this.productId,
    required this.marketType,
    required this.countryId,
    this.unseenPage,
    this.unseenLimit,
    this.seenPage,
    this.seenLimit,
    @Deprecated('Use unseenPage and seenPage instead') this.page,
    @Deprecated('Use unseenLimit and seenLimit instead') this.limit,
  });

  factory ExploreMarketRequestModel.fromJson(Map<String, dynamic> json) {
    return ExploreMarketRequestModel(
      productId: json['productId'] as String,
      marketType: json['marketType'] as String,
      countryId: (json['countryId'] as num).toInt(),
      unseenPage: json['unseenPage'] != null
          ? (json['unseenPage'] as num).toInt()
          : null,
      unseenLimit: json['unseenLimit'] != null
          ? (json['unseenLimit'] as num).toInt()
          : null,
      seenPage: json['seenPage'] != null
          ? (json['seenPage'] as num).toInt()
          : null,
      seenLimit: json['seenLimit'] != null
          ? (json['seenLimit'] as num).toInt()
          : null,
      page: json['page'] != null ? (json['page'] as num).toInt() : null,
      limit: json['limit'] != null ? (json['limit'] as num).toInt() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'marketType': marketType,
      'countryId': countryId,
      if (unseenPage != null) 'unseenPage': unseenPage,
      if (unseenLimit != null) 'unseenLimit': unseenLimit,
      if (seenPage != null) 'seenPage': seenPage,
      if (seenLimit != null) 'seenLimit': seenLimit,
      // Include deprecated fields for backward compatibility
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };
  }
}

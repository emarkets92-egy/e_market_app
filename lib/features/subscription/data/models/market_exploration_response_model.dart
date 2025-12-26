import 'profile_model.dart';
import 'analysis_models.dart';

class MarketExplorationResponseModel {
  final ProductInfo? product;
  final MarketInfo selectedMarket;
  final List<ProfileModel> profiles;
  final CompetitiveAnalysisModel? competitiveAnalysis;
  final PESTLEAnalysisModel? pestleAnalysis;
  final SWOTAnalysisModel? swotAnalysis;
  final MarketPlanModel? marketPlan;
  final PaginationInfo? pagination;

  MarketExplorationResponseModel({
    this.product,
    required this.selectedMarket,
    required this.profiles,
    this.competitiveAnalysis,
    this.pestleAnalysis,
    this.swotAnalysis,
    this.marketPlan,
    this.pagination,
  });

  factory MarketExplorationResponseModel.fromJson(Map<String, dynamic> json) {
    return MarketExplorationResponseModel(
      product: json['product'] != null
          ? ProductInfo.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      selectedMarket:
          MarketInfo.fromJson(json['selectedMarket'] as Map<String, dynamic>),
      profiles: (json['profiles'] as List<dynamic>?)
              ?.map((e) => ProfileModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      competitiveAnalysis: json['competitiveAnalysis'] != null
          ? CompetitiveAnalysisModel.fromJson(
              json['competitiveAnalysis'] as Map<String, dynamic>)
          : null,
      pestleAnalysis: json['pestleAnalysis'] != null
          ? PESTLEAnalysisModel.fromJson(
              json['pestleAnalysis'] as Map<String, dynamic>)
          : null,
      swotAnalysis: json['swotAnalysis'] != null
          ? SWOTAnalysisModel.fromJson(
              json['swotAnalysis'] as Map<String, dynamic>)
          : null,
      marketPlan: json['marketPlan'] != null
          ? MarketPlanModel.fromJson(
              json['marketPlan'] as Map<String, dynamic>)
          : null,
      pagination: json['pagination'] != null
          ? PaginationInfo.fromJson(
              json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (product != null) 'product': product!.toJson(),
      'selectedMarket': selectedMarket.toJson(),
      'profiles': profiles.map((e) => e.toJson()).toList(),
      if (competitiveAnalysis != null)
        'competitiveAnalysis': competitiveAnalysis!.toJson(),
      if (pestleAnalysis != null) 'pestleAnalysis': pestleAnalysis!.toJson(),
      if (swotAnalysis != null) 'swotAnalysis': swotAnalysis!.toJson(),
      if (marketPlan != null) 'marketPlan': marketPlan!.toJson(),
      if (pagination != null) 'pagination': pagination!.toJson(),
    };
  }

  MarketExplorationResponseModel copyWith({
    ProductInfo? product,
    MarketInfo? selectedMarket,
    List<ProfileModel>? profiles,
    CompetitiveAnalysisModel? competitiveAnalysis,
    PESTLEAnalysisModel? pestleAnalysis,
    SWOTAnalysisModel? swotAnalysis,
    MarketPlanModel? marketPlan,
    PaginationInfo? pagination,
  }) {
    return MarketExplorationResponseModel(
      product: product ?? this.product,
      selectedMarket: selectedMarket ?? this.selectedMarket,
      profiles: profiles ?? this.profiles,
      competitiveAnalysis: competitiveAnalysis ?? this.competitiveAnalysis,
      pestleAnalysis: pestleAnalysis ?? this.pestleAnalysis,
      swotAnalysis: swotAnalysis ?? this.swotAnalysis,
      marketPlan: marketPlan ?? this.marketPlan,
      pagination: pagination ?? this.pagination,
    );
  }
}

class ProductInfo {
  final String id;
  final String name;
  final String? hscode;

  ProductInfo({
    required this.id,
    required this.name,
    this.hscode,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      hscode: json['hscode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (hscode != null) 'hscode': hscode,
    };
  }
}

class MarketInfo {
  final String countryName;
  final String productName;
  final String? marketType;

  MarketInfo({
    required this.countryName,
    required this.productName,
    this.marketType,
  });

  factory MarketInfo.fromJson(Map<String, dynamic> json) {
    return MarketInfo(
      countryName: json['countryName'] as String,
      productName: json['productName'] as String,
      marketType: json['marketType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryName': countryName,
      'productName': productName,
      if (marketType != null) 'marketType': marketType,
    };
  }
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }
}

import 'profile_model.dart';
import 'analysis_models.dart';

class MarketExplorationResponseModel {
  final ProductInfo product;
  final MarketInfo selectedMarket;
  final List<ProfileModel> profiles;
  final List<CompetitiveAnalysisModel>? competitiveAnalysis;
  final PESTLEAnalysisModel? pestleAnalysis;
  final SWOTAnalysisModel? swotAnalysis;
  final MarketPlanModel? marketPlan;
  final PaginationInfo? pagination;

  MarketExplorationResponseModel({
    required this.product,
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
      product: ProductInfo.fromJson(json['product'] as Map<String, dynamic>),
      selectedMarket:
          MarketInfo.fromJson(json['selectedMarket'] as Map<String, dynamic>),
      profiles: (json['profiles'] as List<dynamic>?)
              ?.map((e) => ProfileModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      competitiveAnalysis: (json['competitiveAnalysis'] as List<dynamic>?)
          ?.map((e) =>
              CompetitiveAnalysisModel.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      'product': product.toJson(),
      'selectedMarket': selectedMarket.toJson(),
      'profiles': profiles.map((e) => e.toJson()).toList(),
      if (competitiveAnalysis != null)
        'competitiveAnalysis':
            competitiveAnalysis!.map((e) => e.toJson()).toList(),
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
    List<CompetitiveAnalysisModel>? competitiveAnalysis,
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
  final int id;
  final String code;
  final String name;
  final String? marketType;

  MarketInfo({
    required this.id,
    required this.code,
    required this.name,
    this.marketType,
  });

  factory MarketInfo.fromJson(Map<String, dynamic> json) {
    return MarketInfo(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      marketType: json['marketType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
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

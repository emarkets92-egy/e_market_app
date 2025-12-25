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

  MarketExplorationResponseModel({
    required this.product,
    required this.selectedMarket,
    required this.profiles,
    this.competitiveAnalysis,
    this.pestleAnalysis,
    this.swotAnalysis,
    this.marketPlan,
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
  }) {
    return MarketExplorationResponseModel(
      product: product ?? this.product,
      selectedMarket: selectedMarket ?? this.selectedMarket,
      profiles: profiles ?? this.profiles,
      competitiveAnalysis: competitiveAnalysis ?? this.competitiveAnalysis,
      pestleAnalysis: pestleAnalysis ?? this.pestleAnalysis,
      swotAnalysis: swotAnalysis ?? this.swotAnalysis,
      marketPlan: marketPlan ?? this.marketPlan,
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

  MarketInfo({
    required this.id,
    required this.code,
    required this.name,
  });

  factory MarketInfo.fromJson(Map<String, dynamic> json) {
    return MarketInfo(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}

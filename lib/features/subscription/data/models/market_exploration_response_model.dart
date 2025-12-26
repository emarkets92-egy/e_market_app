import 'profile_model.dart';
import 'analysis_models.dart';

class MarketExplorationResponseModel {
  final MarketInfo selectedMarket;
  final ProfileList? unseenProfiles;
  final ProfileList? seenProfiles;
  final CompetitiveAnalysisModel? competitiveAnalysis;
  final PESTLEAnalysisModel? pestleAnalysis;
  final SWOTAnalysisModel? swotAnalysis;
  final MarketPlanModel? marketPlan;

  MarketExplorationResponseModel({
    required this.selectedMarket,
    this.unseenProfiles,
    this.seenProfiles,
    this.competitiveAnalysis,
    this.pestleAnalysis,
    this.swotAnalysis,
    this.marketPlan,
  });

  factory MarketExplorationResponseModel.fromJson(Map<String, dynamic> json) {
    return MarketExplorationResponseModel(
      selectedMarket:
          MarketInfo.fromJson(json['selectedMarket'] as Map<String, dynamic>),
      unseenProfiles: json['unseenProfiles'] != null
          ? ProfileList.fromJson(
              json['unseenProfiles'] as Map<String, dynamic>)
          : null,
      seenProfiles: json['seenProfiles'] != null
          ? ProfileList.fromJson(
              json['seenProfiles'] as Map<String, dynamic>)
          : null,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedMarket': selectedMarket.toJson(),
      if (unseenProfiles != null) 'unseenProfiles': unseenProfiles!.toJson(),
      if (seenProfiles != null) 'seenProfiles': seenProfiles!.toJson(),
      if (competitiveAnalysis != null)
        'competitiveAnalysis': competitiveAnalysis!.toJson(),
      if (pestleAnalysis != null) 'pestleAnalysis': pestleAnalysis!.toJson(),
      if (swotAnalysis != null) 'swotAnalysis': swotAnalysis!.toJson(),
      if (marketPlan != null) 'marketPlan': marketPlan!.toJson(),
    };
  }

  MarketExplorationResponseModel copyWith({
    MarketInfo? selectedMarket,
    ProfileList? unseenProfiles,
    ProfileList? seenProfiles,
    CompetitiveAnalysisModel? competitiveAnalysis,
    PESTLEAnalysisModel? pestleAnalysis,
    SWOTAnalysisModel? swotAnalysis,
    MarketPlanModel? marketPlan,
  }) {
    return MarketExplorationResponseModel(
      selectedMarket: selectedMarket ?? this.selectedMarket,
      unseenProfiles: unseenProfiles ?? this.unseenProfiles,
      seenProfiles: seenProfiles ?? this.seenProfiles,
      competitiveAnalysis: competitiveAnalysis ?? this.competitiveAnalysis,
      pestleAnalysis: pestleAnalysis ?? this.pestleAnalysis,
      swotAnalysis: swotAnalysis ?? this.swotAnalysis,
      marketPlan: marketPlan ?? this.marketPlan,
    );
  }
}

class ProfileList {
  final List<ProfileModel> data;
  final PaginationInfo pagination;

  ProfileList({
    required this.data,
    required this.pagination,
  });

  factory ProfileList.fromJson(Map<String, dynamic> json) {
    return ProfileList(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ProfileModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: PaginationInfo.fromJson(
          json['pagination'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }

  ProfileList copyWith({
    List<ProfileModel>? data,
    PaginationInfo? pagination,
  }) {
    return ProfileList(
      data: data ?? this.data,
      pagination: pagination ?? this.pagination,
    );
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

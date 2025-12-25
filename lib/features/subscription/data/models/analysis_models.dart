class CompetitiveAnalysisModel {
  final String id;
  final String marketName;
  final String totalImports;
  final String totalExportsFromSelectedCountry;
  final int rank;
  final bool isSeen;
  final int unlockCost;

  CompetitiveAnalysisModel({
    required this.id,
    required this.marketName,
    required this.totalImports,
    required this.totalExportsFromSelectedCountry,
    required this.rank,
    required this.isSeen,
    required this.unlockCost,
  });

  factory CompetitiveAnalysisModel.fromJson(Map<String, dynamic> json) {
    return CompetitiveAnalysisModel(
      id: json['id'] as String,
      marketName: json['marketName'] as String,
      totalImports: json['totalImports'] as String,
      totalExportsFromSelectedCountry:
          json['totalExportsFromSelectedCountry'] as String,
      rank: (json['rank'] as num).toInt(),
      isSeen: json['isSeen'] as bool,
      unlockCost: (json['unlockCost'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marketName': marketName,
      'totalImports': totalImports,
      'totalExportsFromSelectedCountry': totalExportsFromSelectedCountry,
      'rank': rank,
      'isSeen': isSeen,
      'unlockCost': unlockCost,
    };
  }

  CompetitiveAnalysisModel copyWith({
    String? id,
    String? marketName,
    String? totalImports,
    String? totalExportsFromSelectedCountry,
    int? rank,
    bool? isSeen,
    int? unlockCost,
  }) {
    return CompetitiveAnalysisModel(
      id: id ?? this.id,
      marketName: marketName ?? this.marketName,
      totalImports: totalImports ?? this.totalImports,
      totalExportsFromSelectedCountry:
          totalExportsFromSelectedCountry ?? this.totalExportsFromSelectedCountry,
      rank: rank ?? this.rank,
      isSeen: isSeen ?? this.isSeen,
      unlockCost: unlockCost ?? this.unlockCost,
    );
  }
}

class PESTLEAnalysisModel {
  final String? political;
  final String? economic;
  final String? social;
  final String? technological;
  final String? legal;
  final String? environmental;
  final bool isSeen;
  final int unlockCost;

  PESTLEAnalysisModel({
    this.political,
    this.economic,
    this.social,
    this.technological,
    this.legal,
    this.environmental,
    required this.isSeen,
    required this.unlockCost,
  });

  factory PESTLEAnalysisModel.fromJson(Map<String, dynamic> json) {
    return PESTLEAnalysisModel(
      political: json['political'] as String?,
      economic: json['economic'] as String?,
      social: json['social'] as String?,
      technological: json['technological'] as String?,
      legal: json['legal'] as String?,
      environmental: json['environmental'] as String?,
      isSeen: json['isSeen'] as bool,
      unlockCost: (json['unlockCost'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (political != null) 'political': political,
      if (economic != null) 'economic': economic,
      if (social != null) 'social': social,
      if (technological != null) 'technological': technological,
      if (legal != null) 'legal': legal,
      if (environmental != null) 'environmental': environmental,
      'isSeen': isSeen,
      'unlockCost': unlockCost,
    };
  }

  PESTLEAnalysisModel copyWith({
    String? political,
    String? economic,
    String? social,
    String? technological,
    String? legal,
    String? environmental,
    bool? isSeen,
    int? unlockCost,
  }) {
    return PESTLEAnalysisModel(
      political: political ?? this.political,
      economic: economic ?? this.economic,
      social: social ?? this.social,
      technological: technological ?? this.technological,
      legal: legal ?? this.legal,
      environmental: environmental ?? this.environmental,
      isSeen: isSeen ?? this.isSeen,
      unlockCost: unlockCost ?? this.unlockCost,
    );
  }
}

class SWOTAnalysisModel {
  final String? strengths;
  final String? weaknesses;
  final String? opportunities;
  final String? threats;
  final bool isSeen;
  final int unlockCost;

  SWOTAnalysisModel({
    this.strengths,
    this.weaknesses,
    this.opportunities,
    this.threats,
    required this.isSeen,
    required this.unlockCost,
  });

  factory SWOTAnalysisModel.fromJson(Map<String, dynamic> json) {
    return SWOTAnalysisModel(
      strengths: json['strengths'] as String?,
      weaknesses: json['weaknesses'] as String?,
      opportunities: json['opportunities'] as String?,
      threats: json['threats'] as String?,
      isSeen: json['isSeen'] as bool,
      unlockCost: (json['unlockCost'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (strengths != null) 'strengths': strengths,
      if (weaknesses != null) 'weaknesses': weaknesses,
      if (opportunities != null) 'opportunities': opportunities,
      if (threats != null) 'threats': threats,
      'isSeen': isSeen,
      'unlockCost': unlockCost,
    };
  }

  SWOTAnalysisModel copyWith({
    String? strengths,
    String? weaknesses,
    String? opportunities,
    String? threats,
    bool? isSeen,
    int? unlockCost,
  }) {
    return SWOTAnalysisModel(
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      opportunities: opportunities ?? this.opportunities,
      threats: threats ?? this.threats,
      isSeen: isSeen ?? this.isSeen,
      unlockCost: unlockCost ?? this.unlockCost,
    );
  }
}

class MarketPlanModel {
  final String? productText;
  final String? priceText;
  final String? placeText;
  final String? promotionText;
  final bool isSeen;
  final int unlockCost;

  MarketPlanModel({
    this.productText,
    this.priceText,
    this.placeText,
    this.promotionText,
    required this.isSeen,
    required this.unlockCost,
  });

  factory MarketPlanModel.fromJson(Map<String, dynamic> json) {
    return MarketPlanModel(
      productText: json['productText'] as String?,
      priceText: json['priceText'] as String?,
      placeText: json['placeText'] as String?,
      promotionText: json['promotionText'] as String?,
      isSeen: json['isSeen'] as bool,
      unlockCost: (json['unlockCost'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (productText != null) 'productText': productText,
      if (priceText != null) 'priceText': priceText,
      if (placeText != null) 'placeText': placeText,
      if (promotionText != null) 'promotionText': promotionText,
      'isSeen': isSeen,
      'unlockCost': unlockCost,
    };
  }

  MarketPlanModel copyWith({
    String? productText,
    String? priceText,
    String? placeText,
    String? promotionText,
    bool? isSeen,
    int? unlockCost,
  }) {
    return MarketPlanModel(
      productText: productText ?? this.productText,
      priceText: priceText ?? this.priceText,
      placeText: placeText ?? this.placeText,
      promotionText: promotionText ?? this.promotionText,
      isSeen: isSeen ?? this.isSeen,
      unlockCost: unlockCost ?? this.unlockCost,
    );
  }
}

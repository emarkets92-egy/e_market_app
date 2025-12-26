class CompetitiveAnalysisModel {
  final String id;
  final String? productId;
  final int? targetCountryId;
  final String? marketName;
  final String? totalImports;
  final String? totalExportsFromSelectedCountry;
  final int? rank;
  final bool isSeen;
  final int unlockCost;
  final String? createdAt;
  final String? updatedAt;

  CompetitiveAnalysisModel({
    required this.id,
    this.productId,
    this.targetCountryId,
    this.marketName,
    this.totalImports,
    this.totalExportsFromSelectedCountry,
    this.rank,
    required this.isSeen,
    required this.unlockCost,
    this.createdAt,
    this.updatedAt,
  });

  factory CompetitiveAnalysisModel.fromJson(Map<String, dynamic> json) {
    return CompetitiveAnalysisModel(
      id: json['id'] as String,
      productId: json['productId'] as String?,
      targetCountryId: json['targetCountryId'] != null
          ? (json['targetCountryId'] as num).toInt()
          : null,
      marketName: json['marketName'] as String?,
      totalImports: json['totalImports'] as String?,
      totalExportsFromSelectedCountry:
          json['totalExportsFromSelectedCountry'] as String?,
      rank: json['rank'] != null ? (json['rank'] as num).toInt() : null,
      isSeen: json['isSeen'] as bool,
      unlockCost: (json['unlockCost'] as num).toInt(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (productId != null) 'productId': productId,
      if (targetCountryId != null) 'targetCountryId': targetCountryId,
      if (marketName != null) 'marketName': marketName,
      if (totalImports != null) 'totalImports': totalImports,
      if (totalExportsFromSelectedCountry != null)
        'totalExportsFromSelectedCountry': totalExportsFromSelectedCountry,
      if (rank != null) 'rank': rank,
      'isSeen': isSeen,
      'unlockCost': unlockCost,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  CompetitiveAnalysisModel copyWith({
    String? id,
    String? productId,
    int? targetCountryId,
    String? marketName,
    String? totalImports,
    String? totalExportsFromSelectedCountry,
    int? rank,
    bool? isSeen,
    int? unlockCost,
    String? createdAt,
    String? updatedAt,
  }) {
    return CompetitiveAnalysisModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      targetCountryId: targetCountryId ?? this.targetCountryId,
      marketName: marketName ?? this.marketName,
      totalImports: totalImports ?? this.totalImports,
      totalExportsFromSelectedCountry:
          totalExportsFromSelectedCountry ?? this.totalExportsFromSelectedCountry,
      rank: rank ?? this.rank,
      isSeen: isSeen ?? this.isSeen,
      unlockCost: unlockCost ?? this.unlockCost,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PESTLEAnalysisModel {
  final String? id;
  final String? productId;
  final int? targetCountryId;
  final String? political;
  final String? economic;
  final String? social;
  final String? technological;
  final String? legal;
  final String? environmental;
  final bool isSeen;
  final int unlockCost;
  final String? createdAt;
  final String? updatedAt;

  PESTLEAnalysisModel({
    this.id,
    this.productId,
    this.targetCountryId,
    this.political,
    this.economic,
    this.social,
    this.technological,
    this.legal,
    this.environmental,
    required this.isSeen,
    required this.unlockCost,
    this.createdAt,
    this.updatedAt,
  });

  factory PESTLEAnalysisModel.fromJson(Map<String, dynamic> json) {
    return PESTLEAnalysisModel(
      id: json['id'] as String?,
      productId: json['productId'] as String?,
      targetCountryId: json['targetCountryId'] != null
          ? (json['targetCountryId'] as num).toInt()
          : null,
      political: json['political'] as String?,
      economic: json['economic'] as String?,
      social: json['social'] as String?,
      technological: json['technological'] as String?,
      legal: json['legal'] as String?,
      environmental: json['environmental'] as String?,
      isSeen: json['isSeen'] as bool,
      unlockCost: (json['unlockCost'] as num).toInt(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (productId != null) 'productId': productId,
      if (targetCountryId != null) 'targetCountryId': targetCountryId,
      if (political != null) 'political': political,
      if (economic != null) 'economic': economic,
      if (social != null) 'social': social,
      if (technological != null) 'technological': technological,
      if (legal != null) 'legal': legal,
      if (environmental != null) 'environmental': environmental,
      'isSeen': isSeen,
      'unlockCost': unlockCost,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  PESTLEAnalysisModel copyWith({
    String? id,
    String? productId,
    int? targetCountryId,
    String? political,
    String? economic,
    String? social,
    String? technological,
    String? legal,
    String? environmental,
    bool? isSeen,
    int? unlockCost,
    String? createdAt,
    String? updatedAt,
  }) {
    return PESTLEAnalysisModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      targetCountryId: targetCountryId ?? this.targetCountryId,
      political: political ?? this.political,
      economic: economic ?? this.economic,
      social: social ?? this.social,
      technological: technological ?? this.technological,
      legal: legal ?? this.legal,
      environmental: environmental ?? this.environmental,
      isSeen: isSeen ?? this.isSeen,
      unlockCost: unlockCost ?? this.unlockCost,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SWOTAnalysisModel {
  final String? id;
  final String? productId;
  final int? targetCountryId;
  final String? strengths;
  final String? weaknesses;
  final String? opportunities;
  final String? threats;
  final bool isSeen;
  final int unlockCost;
  final String? createdAt;
  final String? updatedAt;

  SWOTAnalysisModel({
    this.id,
    this.productId,
    this.targetCountryId,
    this.strengths,
    this.weaknesses,
    this.opportunities,
    this.threats,
    required this.isSeen,
    required this.unlockCost,
    this.createdAt,
    this.updatedAt,
  });

  factory SWOTAnalysisModel.fromJson(Map<String, dynamic> json) {
    return SWOTAnalysisModel(
      id: json['id'] as String?,
      productId: json['productId'] as String?,
      targetCountryId: json['targetCountryId'] != null
          ? (json['targetCountryId'] as num).toInt()
          : null,
      strengths: json['strengths'] as String?,
      weaknesses: json['weaknesses'] as String?,
      opportunities: json['opportunities'] as String?,
      threats: json['threats'] as String?,
      isSeen: json['isSeen'] as bool,
      unlockCost: (json['unlockCost'] as num).toInt(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (productId != null) 'productId': productId,
      if (targetCountryId != null) 'targetCountryId': targetCountryId,
      if (strengths != null) 'strengths': strengths,
      if (weaknesses != null) 'weaknesses': weaknesses,
      if (opportunities != null) 'opportunities': opportunities,
      if (threats != null) 'threats': threats,
      'isSeen': isSeen,
      'unlockCost': unlockCost,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  SWOTAnalysisModel copyWith({
    String? id,
    String? productId,
    int? targetCountryId,
    String? strengths,
    String? weaknesses,
    String? opportunities,
    String? threats,
    bool? isSeen,
    int? unlockCost,
    String? createdAt,
    String? updatedAt,
  }) {
    return SWOTAnalysisModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      targetCountryId: targetCountryId ?? this.targetCountryId,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      opportunities: opportunities ?? this.opportunities,
      threats: threats ?? this.threats,
      isSeen: isSeen ?? this.isSeen,
      unlockCost: unlockCost ?? this.unlockCost,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MarketPlanModel {
  final String? id;
  final String? productText;
  final String? priceText;
  final String? placeText;
  final String? promotionText;
  final bool isSeen;
  final int unlockCost;

  MarketPlanModel({
    this.id,
    this.productText,
    this.priceText,
    this.placeText,
    this.promotionText,
    required this.isSeen,
    required this.unlockCost,
  });

  factory MarketPlanModel.fromJson(Map<String, dynamic> json) {
    return MarketPlanModel(
      id: json['id'] as String?,
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
      if (id != null) 'id': id,
      if (productText != null) 'productText': productText,
      if (priceText != null) 'priceText': priceText,
      if (placeText != null) 'placeText': placeText,
      if (promotionText != null) 'promotionText': promotionText,
      'isSeen': isSeen,
      'unlockCost': unlockCost,
    };
  }

  MarketPlanModel copyWith({
    String? id,
    String? productText,
    String? priceText,
    String? placeText,
    String? promotionText,
    bool? isSeen,
    int? unlockCost,
  }) {
    return MarketPlanModel(
      id: id ?? this.id,
      productText: productText ?? this.productText,
      priceText: priceText ?? this.priceText,
      placeText: placeText ?? this.placeText,
      promotionText: promotionText ?? this.promotionText,
      isSeen: isSeen ?? this.isSeen,
      unlockCost: unlockCost ?? this.unlockCost,
    );
  }
}

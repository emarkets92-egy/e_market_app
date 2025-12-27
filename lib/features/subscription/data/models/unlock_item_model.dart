enum ContentType {
  profileContact,
  marketPlan,
  competitiveAnalysis,
  pestleAnalysis,
  swotAnalysis,
  shipmentRecords;

  static ContentType? fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PROFILE_CONTACT':
        return ContentType.profileContact;
      case 'MARKET_PLAN':
        return ContentType.marketPlan;
      case 'COMPETITIVE_ANALYSIS':
        return ContentType.competitiveAnalysis;
      case 'PESTLE_ANALYSIS':
        return ContentType.pestleAnalysis;
      case 'SWOT_ANALYSIS':
        return ContentType.swotAnalysis;
      case 'SHIPMENT_RECORDS':
        return ContentType.shipmentRecords;
      default:
        return null;
    }
  }

  String toApiString() {
    switch (this) {
      case ContentType.profileContact:
        return 'PROFILE_CONTACT';
      case ContentType.marketPlan:
        return 'MARKET_PLAN';
      case ContentType.competitiveAnalysis:
        return 'COMPETITIVE_ANALYSIS';
      case ContentType.pestleAnalysis:
        return 'PESTLE_ANALYSIS';
      case ContentType.swotAnalysis:
        return 'SWOT_ANALYSIS';
      case ContentType.shipmentRecords:
        return 'SHIPMENT_RECORDS';
    }
  }
}

class UnlockItemModel {
  final String id;
  final ContentType contentType;
  final String contentKey;
  final int cost;
  final DateTime createdAt;

  UnlockItemModel({
    required this.id,
    required this.contentType,
    required this.contentKey,
    required this.cost,
    required this.createdAt,
  });

  factory UnlockItemModel.fromJson(Map<String, dynamic> json) {
    return UnlockItemModel(
      id: json['id'] as String,
      contentType:
          ContentType.fromString(json['contentType'] as String) ??
          ContentType.profileContact,
      contentKey: json['contentKey'] as String,
      cost: (json['cost'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentType': contentType.toApiString(),
      'contentKey': contentKey,
      'cost': cost,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

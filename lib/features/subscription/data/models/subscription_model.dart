import '../../../../features/localization/data/models/country_model.dart';

class SubscriptionModel {
  final String id;
  final String productId;
  final String productName;
  final String? productHscode;
  final int countryId;
  final String subscriptionType;
  final DateTime startDate;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CountryModel>? targetMarkets;
  final List<CountryModel>? otherMarkets;
  final List<CountryModel>? importerMarkets;

  SubscriptionModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productHscode,
    required this.countryId,
    required this.subscriptionType,
    required this.startDate,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.targetMarkets,
    this.otherMarkets,
    this.importerMarkets,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productHscode: json['productHscode'] as String?,
      countryId: (json['countryId'] as num).toInt(),
      subscriptionType: json['subscriptionType'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      active: json['active'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      targetMarkets: json['targetMarkets'] != null
          ? (json['targetMarkets'] as List<dynamic>).map((e) => CountryModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      otherMarkets: json['otherMarkets'] != null
          ? (json['otherMarkets'] as List<dynamic>).map((e) => CountryModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      importerMarkets: json['importerMarkets'] != null
          ? (json['importerMarkets'] as List<dynamic>).map((e) => CountryModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      if (productHscode != null) 'productHscode': productHscode,
      'countryId': countryId,
      'subscriptionType': subscriptionType,
      'startDate': startDate.toIso8601String(),
      'active': active,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (targetMarkets != null) 'targetMarkets': targetMarkets!.map((e) => e.toJson()).toList(),
      if (otherMarkets != null) 'otherMarkets': otherMarkets!.map((e) => e.toJson()).toList(),
      if (importerMarkets != null) 'importerMarkets': importerMarkets!.map((e) => e.toJson()).toList(),
    };
  }
}

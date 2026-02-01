import 'market_exploration_response_model.dart';

class ShipmentRecordModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int year;
  final int month;
  final String? exporterName;
  final String? countryOfOrigin;
  final String? netWeight;
  final String? netWeightUnit;
  final String? portOfArrival;
  final String? portOfDeparture;
  final String? notifyParty;
  final String? notifyAddress;
  final String? hsCode;
  final double? quantity;
  final double? value;
  final bool isSeen;
  final int unlockCost;
  final DateTime? unlockedAt;
  // New fields added
  final String? productDetails;
  final String? quantityUnit;
  final double? amountUsd;
  final double? fobUsd;
  final double? cifUsd;

  ShipmentRecordModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.year,
    required this.month,
    this.exporterName,
    this.countryOfOrigin,
    this.netWeight,
    this.netWeightUnit,
    this.portOfArrival,
    this.portOfDeparture,
    this.notifyParty,
    this.notifyAddress,
    this.hsCode,
    this.quantity,
    this.value,
    required this.isSeen,
    required this.unlockCost,
    this.unlockedAt,
    this.productDetails,
    this.quantityUnit,
    this.amountUsd,
    this.fobUsd,
    this.cifUsd,
  });

  factory ShipmentRecordModel.fromJson(Map<String, dynamic> json, {bool? isSeen}) {
    final createdAt = DateTime.parse(json['createdAt'] as String);
    // Extract year and month from createdAt if not provided in JSON
    final year = json['year'] != null ? (json['year'] as num).toInt() : createdAt.year;
    final month = json['month'] != null ? (json['month'] as num).toInt() : createdAt.month;
    
    return ShipmentRecordModel(
      id: json['id'] as String,
      createdAt: createdAt,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      year: year,
      month: month,
      exporterName: json['exporterName'] as String?,
      countryOfOrigin: json['countryOfOrigin'] as String?,
      netWeight: json['netWeight'] as String?,
      netWeightUnit: json['netWeightUnit'] as String?,
      portOfArrival: json['portOfArrival'] as String?,
      portOfDeparture: json['portOfDeparture'] as String?,
      notifyParty: json['notifyParty'] as String?,
      notifyAddress: json['notifyAddress'] as String?,
      hsCode: json['hsCode'] as String?,
      quantity: json['quantity'] != null ? (json['quantity'] as num).toDouble() : null,
      value: json['value'] != null ? (json['value'] as num).toDouble() : null,
      isSeen: isSeen ?? json['isSeen'] as bool? ?? false,
      unlockCost: json['unlockCost'] != null ? (json['unlockCost'] as num).toInt() : 0,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt'] as String) : null,
      productDetails: json['productDetails'] as String?,
      quantityUnit: json['quantityUnit'] as String?,
      amountUsd: json['amountUsd'] != null ? (json['amountUsd'] as num).toDouble() : null,
      fobUsd: json['fobUsd'] != null ? (json['fobUsd'] as num).toDouble() : null,
      cifUsd: json['cifUsd'] != null ? (json['cifUsd'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'year': year,
      'month': month,
      if (exporterName != null) 'exporterName': exporterName,
      if (countryOfOrigin != null) 'countryOfOrigin': countryOfOrigin,
      if (netWeight != null) 'netWeight': netWeight,
      if (netWeightUnit != null) 'netWeightUnit': netWeightUnit,
      if (portOfArrival != null) 'portOfArrival': portOfArrival,
      if (portOfDeparture != null) 'portOfDeparture': portOfDeparture,
      if (notifyParty != null) 'notifyParty': notifyParty,
      if (notifyAddress != null) 'notifyAddress': notifyAddress,
      if (hsCode != null) 'hsCode': hsCode,
      if (quantity != null) 'quantity': quantity,
      if (value != null) 'value': value,
      'isSeen': isSeen,
      'unlockCost': unlockCost,
      if (unlockedAt != null) 'unlockedAt': unlockedAt!.toIso8601String(),
      if (productDetails != null) 'productDetails': productDetails,
      if (quantityUnit != null) 'quantityUnit': quantityUnit,
      if (amountUsd != null) 'amountUsd': amountUsd,
      if (fobUsd != null) 'fobUsd': fobUsd,
      if (cifUsd != null) 'cifUsd': cifUsd,
    };
  }

  ShipmentRecordModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? year,
    int? month,
    String? exporterName,
    String? countryOfOrigin,
    String? netWeight,
    String? netWeightUnit,
    String? portOfArrival,
    String? portOfDeparture,
    String? notifyParty,
    String? notifyAddress,
    String? hsCode,
    double? quantity,
    double? value,
    bool? isSeen,
    int? unlockCost,
    DateTime? unlockedAt,
    String? productDetails,
    String? quantityUnit,
    double? amountUsd,
    double? fobUsd,
    double? cifUsd,
  }) {
    return ShipmentRecordModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      year: year ?? this.year,
      month: month ?? this.month,
      exporterName: exporterName ?? this.exporterName,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      netWeight: netWeight ?? this.netWeight,
      netWeightUnit: netWeightUnit ?? this.netWeightUnit,
      portOfArrival: portOfArrival ?? this.portOfArrival,
      portOfDeparture: portOfDeparture ?? this.portOfDeparture,
      notifyParty: notifyParty ?? this.notifyParty,
      notifyAddress: notifyAddress ?? this.notifyAddress,
      hsCode: hsCode ?? this.hsCode,
      quantity: quantity ?? this.quantity,
      value: value ?? this.value,
      isSeen: isSeen ?? this.isSeen,
      unlockCost: unlockCost ?? this.unlockCost,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      productDetails: productDetails ?? this.productDetails,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      amountUsd: amountUsd ?? this.amountUsd,
      fobUsd: fobUsd ?? this.fobUsd,
      cifUsd: cifUsd ?? this.cifUsd,
    );
  }
}

class ShipmentRecordsResponseModel {
  final String profileId;
  final int unlockCost;
  final ShipmentRecordList? seenShipmentRecords;
  final ShipmentRecordList? unseenShipmentRecords;

  ShipmentRecordsResponseModel({required this.profileId, required this.unlockCost, this.seenShipmentRecords, this.unseenShipmentRecords});

  factory ShipmentRecordsResponseModel.fromJson(Map<String, dynamic> json) {
    final seenRecords = json['seenShipmentRecords'] != null
        ? ShipmentRecordList.fromJson(json['seenShipmentRecords'] as Map<String, dynamic>, isSeen: true)
        : null;
    final unseenRecords = json['unseenShipmentRecords'] != null
        ? ShipmentRecordList.fromJson(json['unseenShipmentRecords'] as Map<String, dynamic>, isSeen: false)
        : null;

    return ShipmentRecordsResponseModel(
      profileId: json['profileId'] as String,
      unlockCost: (json['unlockCost'] as num).toInt(),
      seenShipmentRecords: seenRecords,
      unseenShipmentRecords: unseenRecords,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'unlockCost': unlockCost,
      if (seenShipmentRecords != null) 'seenShipmentRecords': seenShipmentRecords!.toJson(),
      if (unseenShipmentRecords != null) 'unseenShipmentRecords': unseenShipmentRecords!.toJson(),
    };
  }
}

class ShipmentRecordList {
  final List<ShipmentRecordModel> data;
  final PaginationInfo pagination;

  ShipmentRecordList({required this.data, required this.pagination});

  factory ShipmentRecordList.fromJson(Map<String, dynamic> json, {bool isSeen = false}) {
    return ShipmentRecordList(
      data: (json['data'] as List<dynamic>?)?.map((e) => ShipmentRecordModel.fromJson(e as Map<String, dynamic>, isSeen: isSeen)).toList() ?? [],
      pagination: PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data.map((e) => e.toJson()).toList(), 'pagination': pagination.toJson()};
  }

  ShipmentRecordList copyWith({List<ShipmentRecordModel>? data, PaginationInfo? pagination}) {
    return ShipmentRecordList(data: data ?? this.data, pagination: pagination ?? this.pagination);
  }
}

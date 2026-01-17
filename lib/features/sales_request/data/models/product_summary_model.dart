class ProductSummaryModel {
  final String id;
  final String name;
  final String? hscode;
  final int? categoryId;
  final int totalShipmentRecords;
  final int totalImporters;
  final int totalExporters;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductSummaryModel({
    required this.id,
    required this.name,
    this.hscode,
    this.categoryId,
    required this.totalShipmentRecords,
    required this.totalImporters,
    required this.totalExporters,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProductSummaryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      hscode: json['hscode'] as String?,
      categoryId: (json['categoryId'] as num?)?.toInt(),
      totalShipmentRecords: (json['totalShipmentRecords'] as num).toInt(),
      totalImporters: (json['totalImporters'] as num).toInt(),
      totalExporters: (json['totalExporters'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (hscode != null) 'hscode': hscode,
      if (categoryId != null) 'categoryId': categoryId,
      'totalShipmentRecords': totalShipmentRecords,
      'totalImporters': totalImporters,
      'totalExporters': totalExporters,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ProductSummaryListResponseModel {
  final List<ProductSummaryModel> data;
  final ProductSummaryMetaModel meta;

  ProductSummaryListResponseModel({
    required this.data,
    required this.meta,
  });

  factory ProductSummaryListResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductSummaryListResponseModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => ProductSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: ProductSummaryMetaModel.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class ProductSummaryMetaModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  ProductSummaryMetaModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory ProductSummaryMetaModel.fromJson(Map<String, dynamic> json) {
    return ProductSummaryMetaModel(
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final String? hscode;
  final int? categoryId;
  final List<int> targetMarkets;
  final List<int> otherMarkets;
  final List<int> importerMarkets;

  ProductModel({
    required this.id,
    required this.name,
    this.hscode,
    this.categoryId,
    required this.targetMarkets,
    required this.otherMarkets,
    required this.importerMarkets,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      hscode: json['hscode'] as String?,
      categoryId: (json['categoryId'] as num?)?.toInt(),
      targetMarkets: (json['targetMarkets'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [],
      otherMarkets: (json['otherMarkets'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [],
      importerMarkets: (json['importerMarkets'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (hscode != null) 'hscode': hscode,
      if (categoryId != null) 'categoryId': categoryId,
      'targetMarkets': targetMarkets,
      'otherMarkets': otherMarkets,
      'importerMarkets': importerMarkets,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? hscode,
    int? categoryId,
    List<int>? targetMarkets,
    List<int>? otherMarkets,
    List<int>? importerMarkets,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      hscode: hscode ?? this.hscode,
      categoryId: categoryId ?? this.categoryId,
      targetMarkets: targetMarkets ?? this.targetMarkets,
      otherMarkets: otherMarkets ?? this.otherMarkets,
      importerMarkets: importerMarkets ?? this.importerMarkets,
    );
  }
}

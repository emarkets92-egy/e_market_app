import 'product_model.dart';

class ProductListResponseModel {
  final List<ProductModel> data;
  final MetaModel meta;

  ProductListResponseModel({required this.data, required this.meta});

  factory ProductListResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductListResponseModel(
      data: (json['data'] as List<dynamic>?)?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      meta: MetaModel.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data.map((e) => e.toJson()).toList(), 'meta': meta.toJson()};
  }
}

class MetaModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  MetaModel({required this.page, required this.limit, required this.total, required this.totalPages});

  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'page': page, 'limit': limit, 'total': total, 'totalPages': totalPages};
  }
}

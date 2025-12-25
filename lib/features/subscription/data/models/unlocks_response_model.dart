import 'unlock_item_model.dart';
import '../../../product/data/models/product_list_response_model.dart';

class UnlocksResponseModel {
  final List<UnlockItemModel> data;
  final MetaModel meta;

  UnlocksResponseModel({
    required this.data,
    required this.meta,
  });

  factory UnlocksResponseModel.fromJson(Map<String, dynamic> json) {
    return UnlocksResponseModel(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => UnlockItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      meta: MetaModel.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}

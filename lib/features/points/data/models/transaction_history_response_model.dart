import 'transaction_model.dart';
import '../../../product/data/models/product_list_response_model.dart';

class TransactionHistoryResponseModel {
  final List<TransactionModel> data;
  final MetaModel meta;

  TransactionHistoryResponseModel({
    required this.data,
    required this.meta,
  });

  factory TransactionHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryResponseModel(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
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

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/product_model.dart';
import '../models/product_list_response_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductListResponseModel> searchProducts({
    String? hscode,
    String? name,
    int page = 1,
    int limit = 20,
    String? locale,
  });
  Future<ProductModel> getProductDetails(String productId, {String? locale});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ProductListResponseModel> searchProducts({
    String? hscode,
    String? name,
    int page = 1,
    int limit = 20,
    String? locale,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (hscode != null && hscode.isNotEmpty) {
        queryParams['hscode'] = hscode;
      }
      if (name != null && name.isNotEmpty) {
        queryParams['name'] = name;
      }
      if (locale != null) {
        queryParams['locale'] = locale;
      }

      final response = await apiClient.get(
        Endpoints.products,
        queryParameters: queryParams,
      );
      return ProductListResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ProductModel> getProductDetails(String productId, {String? locale}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (locale != null) {
        queryParams['locale'] = locale;
      }

      final response = await apiClient.get(
        Endpoints.productById(productId),
        queryParameters: queryParams,
      );
      return ProductModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }
}


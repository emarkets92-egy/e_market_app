import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/sales_request_model.dart';
import '../models/create_sales_request_model.dart';
import '../models/product_summary_model.dart';

abstract class SalesRequestRemoteDataSource {
  Future<SalesRequestModel> createSalesRequest(CreateSalesRequestModel request);
  Future<List<SalesRequestModel>> getSalesRequests();
  Future<SalesRequestModel> getSalesRequestById(String id);
  Future<ProductSummaryListResponseModel> getProductsSummary({
    String? locale,
    int page = 1,
    int limit = 20,
    String? hscode,
    String? name,
  });
}

class SalesRequestRemoteDataSourceImpl implements SalesRequestRemoteDataSource {
  final ApiClient apiClient;

  SalesRequestRemoteDataSourceImpl(this.apiClient);

  @override
  Future<SalesRequestModel> createSalesRequest(CreateSalesRequestModel request) async {
    try {
      final response = await apiClient.post(Endpoints.salesRequests, data: request.toJson());
      return SalesRequestModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<SalesRequestModel>> getSalesRequests() async {
    try {
      final response = await apiClient.get(Endpoints.salesRequests);
      return (response.data as List<dynamic>)
          .map((e) => SalesRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<SalesRequestModel> getSalesRequestById(String id) async {
    try {
      final response = await apiClient.get(Endpoints.salesRequestById(id));
      return SalesRequestModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ProductSummaryListResponseModel> getProductsSummary({
    String? locale,
    int page = 1,
    int limit = 20,
    String? hscode,
    String? name,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (locale != null) queryParams['locale'] = locale;
      if (hscode != null && hscode.isNotEmpty) queryParams['hscode'] = hscode;
      if (name != null && name.isNotEmpty) queryParams['name'] = name;

      final response = await apiClient.get(Endpoints.productsSummary, queryParameters: queryParams);
      return ProductSummaryListResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }
}

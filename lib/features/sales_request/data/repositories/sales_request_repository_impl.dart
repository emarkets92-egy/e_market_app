import '../../domain/repositories/sales_request_repository.dart';
import '../datasources/sales_request_remote_datasource.dart';
import '../models/sales_request_model.dart';
import '../models/create_sales_request_model.dart';
import '../models/product_summary_model.dart';

class SalesRequestRepositoryImpl implements SalesRequestRepository {
  final SalesRequestRemoteDataSource remoteDataSource;

  SalesRequestRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SalesRequestModel> createSalesRequest(CreateSalesRequestModel request) async {
    try {
      return await remoteDataSource.createSalesRequest(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SalesRequestModel>> getSalesRequests() async {
    try {
      return await remoteDataSource.getSalesRequests();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SalesRequestModel> getSalesRequestById(String id) async {
    try {
      return await remoteDataSource.getSalesRequestById(id);
    } catch (e) {
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
      return await remoteDataSource.getProductsSummary(
        locale: locale,
        page: page,
        limit: limit,
        hscode: hscode,
        name: name,
      );
    } catch (e) {
      rethrow;
    }
  }
}

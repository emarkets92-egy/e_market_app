import '../../data/models/sales_request_model.dart';
import '../../data/models/create_sales_request_model.dart';
import '../../data/models/product_summary_model.dart';

abstract class SalesRequestRepository {
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

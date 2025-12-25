import '../../data/models/product_model.dart';
import '../../data/models/product_list_response_model.dart';

abstract class ProductRepository {
  Future<ProductListResponseModel> searchProducts({
    String? hscode,
    String? name,
    int page = 1,
    int limit = 20,
    String? locale,
  });
  Future<ProductModel> getProductDetails(String productId, {String? locale});
}

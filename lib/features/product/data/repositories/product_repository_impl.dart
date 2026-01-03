import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';
import '../models/product_list_response_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProductListResponseModel> searchProducts({String? hscode, String? name, int page = 1, int limit = 20, String? locale}) async {
    try {
      // Server-side search with both HS code and name
      return await remoteDataSource.searchProducts(hscode: hscode, name: name, page: page, limit: limit, locale: locale);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProductModel> getProductDetails(String productId, {String? locale}) async {
    try {
      final product = await remoteDataSource.getProductDetails(productId, locale: locale);
      return product;
    } catch (e) {
      rethrow;
    }
  }
}

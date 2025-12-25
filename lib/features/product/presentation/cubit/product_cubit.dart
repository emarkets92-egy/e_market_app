import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/product_repository.dart';
import '../cubit/product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _repository;

  ProductCubit(this._repository) : super(const ProductState.initial());

  Future<void> searchProducts({
    String? hscode,
    String? name,
    int page = 1,
    int limit = 20,
    String? locale,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await _repository.searchProducts(
        hscode: hscode,
        name: name,
        page: page,
        limit: limit,
        locale: locale,
      );
      emit(
        state.copyWith(
          isLoading: false,
          products: result.data,
          totalPages: result.meta.totalPages,
          currentPage: page,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> getProductDetails(String productId, {String? locale}) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final product = await _repository.getProductDetails(
        productId,
        locale: locale,
      );
      emit(
        state.copyWith(isLoading: false, selectedProduct: product, error: null),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void clearSelectedProduct() {
    emit(state.copyWith(selectedProduct: null));
  }
}

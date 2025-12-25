import '../../data/models/product_model.dart';

class ProductState {
  final bool isLoading;
  final List<ProductModel> products;
  final ProductModel? selectedProduct;
  final int currentPage;
  final int totalPages;
  final String? error;

  const ProductState({
    this.isLoading = false,
    this.products = const [],
    this.selectedProduct,
    this.currentPage = 1,
    this.totalPages = 1,
    this.error,
  });

  const ProductState.initial()
    : isLoading = false,
      products = const [],
      selectedProduct = null,
      currentPage = 1,
      totalPages = 1,
      error = null;

  const ProductState.loading()
    : isLoading = true,
      products = const [],
      selectedProduct = null,
      currentPage = 1,
      totalPages = 1,
      error = null;

  ProductState copyWith({
    bool? isLoading,
    List<ProductModel>? products,
    ProductModel? selectedProduct,
    int? currentPage,
    int? totalPages,
    String? error,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      error: error ?? this.error,
    );
  }
}

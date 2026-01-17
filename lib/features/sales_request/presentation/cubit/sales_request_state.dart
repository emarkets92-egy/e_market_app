import '../../data/models/sales_request_model.dart';
import '../../data/models/product_summary_model.dart';

class SalesRequestState {
  final bool isLoading;
  final List<SalesRequestModel> salesRequests;
  final SalesRequestModel? selectedSalesRequest;
  final List<ProductSummaryModel> products;
  final int currentPage;
  final int totalPages;
  final String? error;

  const SalesRequestState({
    this.isLoading = false,
    this.salesRequests = const [],
    this.selectedSalesRequest,
    this.products = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.error,
  });

  const SalesRequestState.initial()
      : isLoading = false,
        salesRequests = const [],
        selectedSalesRequest = null,
        products = const [],
        currentPage = 1,
        totalPages = 1,
        error = null;

  const SalesRequestState.loading()
      : isLoading = true,
        salesRequests = const [],
        selectedSalesRequest = null,
        products = const [],
        currentPage = 1,
        totalPages = 1,
        error = null;

  SalesRequestState copyWith({
    bool? isLoading,
    List<SalesRequestModel>? salesRequests,
    SalesRequestModel? selectedSalesRequest,
    List<ProductSummaryModel>? products,
    int? currentPage,
    int? totalPages,
    String? error,
  }) {
    return SalesRequestState(
      isLoading: isLoading ?? this.isLoading,
      salesRequests: salesRequests ?? this.salesRequests,
      selectedSalesRequest: selectedSalesRequest ?? this.selectedSalesRequest,
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      error: error ?? this.error,
    );
  }
}

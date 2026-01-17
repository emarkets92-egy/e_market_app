import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/sales_request_repository.dart';
import '../cubit/sales_request_state.dart';
import '../../data/models/create_sales_request_model.dart';

class SalesRequestCubit extends Cubit<SalesRequestState> {
  final SalesRequestRepository _repository;

  SalesRequestCubit(this._repository) : super(const SalesRequestState.initial());

  Future<void> createSalesRequest(CreateSalesRequestModel request) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final salesRequest = await _repository.createSalesRequest(request);
      emit(state.copyWith(
        isLoading: false,
        salesRequests: [salesRequest, ...state.salesRequests],
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> getSalesRequests() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final salesRequests = await _repository.getSalesRequests();
      emit(state.copyWith(isLoading: false, salesRequests: salesRequests, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> getSalesRequestById(String id) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final salesRequest = await _repository.getSalesRequestById(id);
      emit(state.copyWith(isLoading: false, selectedSalesRequest: salesRequest, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> getProductsSummary({
    String? locale,
    int page = 1,
    int limit = 20,
    String? hscode,
    String? name,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await _repository.getProductsSummary(
        locale: locale,
        page: page,
        limit: limit,
        hscode: hscode,
        name: name,
      );
      emit(state.copyWith(
        isLoading: false,
        products: result.data,
        totalPages: result.meta.totalPages,
        currentPage: page,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void clearSelectedSalesRequest() {
    emit(state.copyWith(selectedSalesRequest: null));
  }
}

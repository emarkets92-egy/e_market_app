import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/points_repository.dart';
import '../cubit/points_state.dart';

class PointsCubit extends Cubit<PointsState> {
  final PointsRepository _repository;

  PointsCubit(this._repository) : super(const PointsState.initial());

  Future<void> getBalance() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final balance = await _repository.getBalance();
      emit(
        state.copyWith(
          isLoading: false,
          balance: balance.pointsBalance,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void updateBalance(int newBalance) {
    emit(state.copyWith(balance: newBalance));
  }

  Future<void> getTransactionHistory({int page = 1, int limit = 20}) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await _repository.getTransactionHistory(
        page: page,
        limit: limit,
      );
      emit(
        state.copyWith(
          isLoading: false,
          transactions: result.data,
          transactionsTotalPages: result.meta.totalPages,
          transactionsCurrentPage: result.meta.page,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

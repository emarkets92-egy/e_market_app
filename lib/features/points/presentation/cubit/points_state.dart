import '../../data/models/transaction_model.dart';

class PointsState {
  final bool isLoading;
  final int balance;
  final List<TransactionModel> transactions;
  final int transactionsTotalPages;
  final int transactionsCurrentPage;
  final String? error;

  const PointsState({
    this.isLoading = false,
    this.balance = 0,
    this.transactions = const [],
    this.transactionsTotalPages = 0,
    this.transactionsCurrentPage = 1,
    this.error,
  });

  const PointsState.initial()
    : isLoading = false,
      balance = 0,
      transactions = const [],
      transactionsTotalPages = 0,
      transactionsCurrentPage = 1,
      error = null;

  const PointsState.loading()
    : isLoading = true,
      balance = 0,
      transactions = const [],
      transactionsTotalPages = 0,
      transactionsCurrentPage = 1,
      error = null;

  PointsState copyWith({
    bool? isLoading,
    int? balance,
    List<TransactionModel>? transactions,
    int? transactionsTotalPages,
    int? transactionsCurrentPage,
    String? error,
  }) {
    return PointsState(
      isLoading: isLoading ?? this.isLoading,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      transactionsTotalPages:
          transactionsTotalPages ?? this.transactionsTotalPages,
      transactionsCurrentPage:
          transactionsCurrentPage ?? this.transactionsCurrentPage,
      error: error ?? this.error,
    );
  }
}

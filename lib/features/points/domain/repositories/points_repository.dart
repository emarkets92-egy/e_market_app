import '../../data/models/points_balance_model.dart';
import '../../data/models/transaction_history_response_model.dart';

abstract class PointsRepository {
  Future<PointsBalanceModel> getBalance();
  Future<TransactionHistoryResponseModel> getTransactionHistory({
    int page = 1,
    int limit = 20,
  });
}

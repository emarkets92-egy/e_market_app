import '../../domain/repositories/points_repository.dart';
import '../datasources/points_remote_datasource.dart';
import '../models/points_balance_model.dart';
import '../models/transaction_history_response_model.dart';

class PointsRepositoryImpl implements PointsRepository {
  final PointsRemoteDataSource remoteDataSource;

  PointsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PointsBalanceModel> getBalance() async {
    try {
      final result = await remoteDataSource.getBalance();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TransactionHistoryResponseModel> getTransactionHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await remoteDataSource.getTransactionHistory(
        page: page,
        limit: limit,
      );
    } catch (e) {
      rethrow;
    }
  }
}

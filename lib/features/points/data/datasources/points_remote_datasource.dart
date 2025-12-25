import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/points_balance_model.dart';
import '../models/transaction_history_response_model.dart';

abstract class PointsRemoteDataSource {
  Future<PointsBalanceModel> getBalance();
  Future<TransactionHistoryResponseModel> getTransactionHistory({
    int page = 1,
    int limit = 20,
  });
}

class PointsRemoteDataSourceImpl implements PointsRemoteDataSource {
  final ApiClient apiClient;

  PointsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PointsBalanceModel> getBalance() async {
    try {
      final response = await apiClient.get(Endpoints.pointsBalance);
      return PointsBalanceModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<TransactionHistoryResponseModel> getTransactionHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.get(
        Endpoints.pointsTransactions,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return TransactionHistoryResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }
}


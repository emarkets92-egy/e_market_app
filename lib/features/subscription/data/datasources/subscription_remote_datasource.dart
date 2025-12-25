import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/subscription_model.dart';
import '../models/explore_market_request_model.dart';
import '../models/market_exploration_response_model.dart';
import '../models/unlock_response_model.dart';
import '../models/unlocks_response_model.dart';
import '../models/unlock_item_model.dart';

abstract class SubscriptionRemoteDataSource {
  Future<List<SubscriptionModel>> getSubscriptions({bool activeOnly = true});
  Future<void> subscribe(String productId);
  Future<MarketExplorationResponseModel> exploreMarket(
    ExploreMarketRequestModel request,
  );
  Future<UnlockResponseModel> unlockProfileContact({
    required String productId,
    required String targetProfileId,
  });
  Future<UnlockResponseModel> unlockMarketAnalysis({
    required String productId,
    required int countryId,
    required String analysisType,
  });
  Future<UnlockResponseModel> unlockMarketPlan({
    required String productId,
    required int countryId,
  });
  Future<UnlocksResponseModel> getUnlocks({
    ContentType? contentType,
    int page = 1,
    int limit = 20,
  });
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final ApiClient apiClient;

  SubscriptionRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<SubscriptionModel>> getSubscriptions({
    bool activeOnly = true,
  }) async {
    try {
      final response = await apiClient.get(
        Endpoints.subscriptions,
        queryParameters: {'activeOnly': activeOnly},
      );
      if (response.data is List) {
        return (response.data as List)
            .map((json) => SubscriptionModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> subscribe(String productId) async {
    try {
      await apiClient.post(
        Endpoints.subscriptions,
        data: {'productId': productId},
      );
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<MarketExplorationResponseModel> exploreMarket(
    ExploreMarketRequestModel request,
  ) async {
    try {
      final response = await apiClient.post(
        Endpoints.exploreMarket,
        data: request.toJson(),
      );
      return MarketExplorationResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<UnlockResponseModel> unlockProfileContact({
    required String productId,
    required String targetProfileId,
  }) async {
    try {
      final response = await apiClient.post(
        Endpoints.unlockProfileContact,
        data: {'productId': productId, 'targetProfileId': targetProfileId},
      );
      return UnlockResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<UnlockResponseModel> unlockMarketAnalysis({
    required String productId,
    required int countryId,
    required String analysisType,
  }) async {
    try {
      final response = await apiClient.post(
        Endpoints.unlockMarketAnalysis,
        data: {
          'productId': productId,
          'countryId': countryId,
          'analysisType': analysisType,
        },
      );
      return UnlockResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<UnlockResponseModel> unlockMarketPlan({
    required String productId,
    required int countryId,
  }) async {
    try {
      final response = await apiClient.post(
        Endpoints.unlockMarketPlan,
        data: {'productId': productId, 'countryId': countryId},
      );
      return UnlockResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<UnlocksResponseModel> getUnlocks({
    ContentType? contentType,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (contentType != null) {
        queryParams['contentType'] = contentType.toApiString();
      }

      final response = await apiClient.get(
        Endpoints.unlocks,
        queryParameters: queryParams,
      );
      return UnlocksResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }
}

import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_datasource.dart';
import '../models/subscription_model.dart';
import '../models/market_exploration_response_model.dart';
import '../models/unlock_response_model.dart';
import '../models/explore_market_request_model.dart';
import '../models/unlocks_response_model.dart';
import '../models/unlock_item_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SubscriptionModel>> getSubscriptions({
    bool activeOnly = true,
  }) async {
    try {
      final result = await remoteDataSource.getSubscriptions(
        activeOnly: activeOnly,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> subscribe(String productId) async {
    try {
      await remoteDataSource.subscribe(productId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MarketExplorationResponseModel> exploreMarket(
    ExploreMarketRequestModel request,
  ) async {
    try {
      return await remoteDataSource.exploreMarket(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UnlockResponseModel> unlockProfileContact({
    required String productId,
    required String targetProfileId,
  }) async {
    try {
      return await remoteDataSource.unlockProfileContact(
        productId: productId,
        targetProfileId: targetProfileId,
      );
    } catch (e) {
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
      return await remoteDataSource.unlockMarketAnalysis(
        productId: productId,
        countryId: countryId,
        analysisType: analysisType,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UnlockResponseModel> unlockMarketPlan({
    required String productId,
    required int countryId,
  }) async {
    try {
      return await remoteDataSource.unlockMarketPlan(
        productId: productId,
        countryId: countryId,
      );
    } catch (e) {
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
      return await remoteDataSource.getUnlocks(
        contentType: contentType,
        page: page,
        limit: limit,
      );
    } catch (e) {
      rethrow;
    }
  }
}

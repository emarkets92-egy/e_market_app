import '../../data/models/subscription_model.dart';
import '../../data/models/market_exploration_response_model.dart';
import '../../data/models/unlock_response_model.dart';
import '../../data/models/explore_market_request_model.dart';
import '../../data/models/unlocks_response_model.dart';
import '../../data/models/unlock_item_model.dart';

abstract class SubscriptionRepository {
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

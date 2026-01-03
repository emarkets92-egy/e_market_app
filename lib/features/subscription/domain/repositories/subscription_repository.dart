import '../../data/models/subscription_model.dart';
import '../../data/models/market_exploration_response_model.dart';
import '../../data/models/unlock_response_model.dart';
import '../../data/models/explore_market_request_model.dart';
import '../../data/models/unlock_item_model.dart';
import '../../data/models/shipment_record_model.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionModel>> getSubscriptions({bool activeOnly = true});
  Future<void> subscribe(String productId);
  Future<MarketExplorationResponseModel> exploreMarket(ExploreMarketRequestModel request);
  Future<UnlockResponseModel> unlock({required ContentType contentType, required String targetId});
  Future<ShipmentRecordsResponseModel> getShipmentRecords({required String profileId, int? seenPage, int? seenLimit, int? unseenPage, int? unseenLimit});
}

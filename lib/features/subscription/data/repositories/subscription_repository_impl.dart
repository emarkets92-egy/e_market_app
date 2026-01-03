import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_datasource.dart';
import '../models/subscription_model.dart';
import '../models/market_exploration_response_model.dart';
import '../models/unlock_response_model.dart';
import '../models/explore_market_request_model.dart';
import '../models/unlock_item_model.dart';
import '../models/shipment_record_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SubscriptionModel>> getSubscriptions({bool activeOnly = true}) async {
    try {
      final result = await remoteDataSource.getSubscriptions(activeOnly: activeOnly);
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
  Future<MarketExplorationResponseModel> exploreMarket(ExploreMarketRequestModel request) async {
    try {
      return await remoteDataSource.exploreMarket(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UnlockResponseModel> unlock({required ContentType contentType, required String targetId}) async {
    try {
      return await remoteDataSource.unlock(contentType: contentType, targetId: targetId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ShipmentRecordsResponseModel> getShipmentRecords({required String profileId, int? seenPage, int? seenLimit, int? unseenPage, int? unseenLimit}) async {
    try {
      return await remoteDataSource.getShipmentRecords(
        profileId: profileId,
        seenPage: seenPage,
        seenLimit: seenLimit,
        unseenPage: unseenPage,
        unseenLimit: unseenLimit,
      );
    } catch (e) {
      rethrow;
    }
  }
}

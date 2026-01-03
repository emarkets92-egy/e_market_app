import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/subscription_model.dart';
import '../models/explore_market_request_model.dart';
import '../models/market_exploration_response_model.dart';
import '../models/unlock_response_model.dart';
import '../models/unlock_item_model.dart';
import '../models/shipment_record_model.dart';

abstract class SubscriptionRemoteDataSource {
  Future<List<SubscriptionModel>> getSubscriptions({bool activeOnly = true});
  Future<void> subscribe(String productId);
  Future<MarketExplorationResponseModel> exploreMarket(ExploreMarketRequestModel request);
  Future<UnlockResponseModel> unlock({required ContentType contentType, required String targetId});
  Future<ShipmentRecordsResponseModel> getShipmentRecords({required String profileId, int? seenPage, int? seenLimit, int? unseenPage, int? unseenLimit});
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final ApiClient apiClient;

  SubscriptionRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<SubscriptionModel>> getSubscriptions({bool activeOnly = true}) async {
    try {
      final response = await apiClient.get(Endpoints.subscriptions, queryParameters: {'activeOnly': activeOnly});
      if (response.data is List) {
        return (response.data as List).map((json) => SubscriptionModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> subscribe(String productId) async {
    try {
      await apiClient.post(Endpoints.subscriptions, data: {'productId': productId});
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<MarketExplorationResponseModel> exploreMarket(ExploreMarketRequestModel request) async {
    try {
      // Use extended timeout for exploreMarket API as it can be slow
      final response = await apiClient.post(
        Endpoints.exploreMarket,
        data: request.toJson(),
        options: Options(
          receiveTimeout: const Duration(seconds: 60), // Extended timeout for slow API
        ),
      );

      // Log the response to debug incomplete data issues
      print('🔍 exploreMarket API Response received');
      print('Response keys: ${(response.data as Map<String, dynamic>).keys.toList()}');
      print('Has competitiveAnalysis: ${(response.data as Map<String, dynamic>).containsKey('competitiveAnalysis')}');
      print('Has pestleAnalysis: ${(response.data as Map<String, dynamic>).containsKey('pestleAnalysis')}');
      print('Has swotAnalysis: ${(response.data as Map<String, dynamic>).containsKey('swotAnalysis')}');
      print('Has marketPlan: ${(response.data as Map<String, dynamic>).containsKey('marketPlan')}');

      // Validate response structure
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format: expected Map but got ${response.data.runtimeType}');
      }

      final responseData = response.data as Map<String, dynamic>;

      // Check if response has at least the required fields
      if (!responseData.containsKey('selectedMarket')) {
        throw Exception('Invalid response: missing required field "selectedMarket"');
      }

      return MarketExplorationResponseModel.fromJson(responseData);
    } on DioException catch (e) {
      // Log DioException details for debugging
      print('❌ exploreMarket API Error: ${e.type}');
      print('Error message: ${e.message}');
      if (e.response != null) {
        print('Response status: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('❌ exploreMarket Unexpected Error: $e');
      rethrow;
    }
  }

  @override
  Future<UnlockResponseModel> unlock({required ContentType contentType, required String targetId}) async {
    try {
      final response = await apiClient.post(Endpoints.unlock, data: {'contentType': contentType.toApiString(), 'targetId': targetId});
      return UnlockResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ShipmentRecordsResponseModel> getShipmentRecords({required String profileId, int? seenPage, int? seenLimit, int? unseenPage, int? unseenLimit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (seenPage != null) queryParams['seenPage'] = seenPage;
      if (seenLimit != null) queryParams['seenLimit'] = seenLimit;
      if (unseenPage != null) queryParams['unseenPage'] = unseenPage;
      if (unseenLimit != null) queryParams['unseenLimit'] = unseenLimit;

      final response = await apiClient.get(Endpoints.shipmentRecords(profileId), queryParameters: queryParams.isNotEmpty ? queryParams : null);
      return ShipmentRecordsResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }
}

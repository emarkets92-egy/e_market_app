import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../cubit/subscription_state.dart';
import '../../data/models/explore_market_request_model.dart';
import '../../data/models/unlock_item_model.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../points/presentation/cubit/points_cubit.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionRepository _repository;

  SubscriptionCubit(this._repository)
    : super(const SubscriptionState.initial());

  Future<void> exploreMarket({
    required String productId,
    required String marketType,
    required int countryId,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final request = ExploreMarketRequestModel(
        productId: productId,
        marketType: marketType,
        countryId: countryId,
      );
      final result = await _repository.exploreMarket(request);
      emit(
        state.copyWith(
          isLoading: false,
          marketExploration: result,
          profiles: result.profiles,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> unlockProfile({
    required String productId,
    required String targetProfileId,
  }) async {
    emit(state.copyWith(isUnlocking: true, error: null));

    try {
      final result = await _repository.unlockProfileContact(
        productId: productId,
        targetProfileId: targetProfileId,
      );

      // Update the profile in the list
      final updatedProfiles = state.profiles.map((profile) {
        if (profile.id == targetProfileId) {
          return profile.copyWith(isSeen: true);
        }
        return profile;
      }).toList();

      // Update points balance
      di.sl<PointsCubit>().updateBalance(result.pointsBalance);

      emit(
        state.copyWith(
          isUnlocking: false,
          profiles: updatedProfiles,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isUnlocking: false, error: e.toString()));
    }
  }

  Future<void> unlockAnalysis({
    required String productId,
    required int countryId,
    required String analysisType,
  }) async {
    emit(state.copyWith(isUnlocking: true, error: null));

    try {
      final result = await _repository.unlockMarketAnalysis(
        productId: productId,
        countryId: countryId,
        analysisType: analysisType,
      );

      // Update points balance
      di.sl<PointsCubit>().updateBalance(result.pointsBalance);

      // Update market exploration with unlocked analysis
      final updatedExploration = state.marketExploration?.copyWith(
        // Note: This is simplified - you may need to update specific analysis based on type
      );

      emit(
        state.copyWith(
          isUnlocking: false,
          marketExploration: updatedExploration ?? state.marketExploration,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isUnlocking: false, error: e.toString()));
    }
  }

  Future<void> unlockMarketPlan({
    required String productId,
    required int countryId,
  }) async {
    emit(state.copyWith(isUnlocking: true, error: null));

    try {
      final result = await _repository.unlockMarketPlan(
        productId: productId,
        countryId: countryId,
      );

      // Update points balance
      di.sl<PointsCubit>().updateBalance(result.pointsBalance);

      // Update market exploration with unlocked market plan
      final updatedExploration = state.marketExploration?.copyWith(
        marketPlan: state.marketExploration?.marketPlan?.copyWith(isSeen: true),
      );

      emit(
        state.copyWith(
          isUnlocking: false,
          marketExploration: updatedExploration ?? state.marketExploration,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isUnlocking: false, error: e.toString()));
    }
  }

  Future<void> getUnlocks({
    ContentType? contentType,
    int page = 1,
    int limit = 20,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await _repository.getUnlocks(
        contentType: contentType,
        page: page,
        limit: limit,
      );
      emit(
        state.copyWith(
          isLoading: false,
          unlocks: result.data,
          unlocksTotalPages: result.meta.totalPages,
          unlocksCurrentPage: result.meta.page,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

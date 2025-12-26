import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../cubit/subscription_state.dart';
import '../../data/models/explore_market_request_model.dart';
import '../../data/models/unlock_item_model.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/presentation/cubit/auth_cubit.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionRepository _repository;

  SubscriptionCubit(this._repository)
    : super(const SubscriptionState.initial());

  Future<void> getSubscriptions({bool activeOnly = true}) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final subscriptions = await _repository.getSubscriptions(
        activeOnly: activeOnly,
      );
      emit(
        state.copyWith(
          isLoading: false,
          subscriptions: subscriptions,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

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

  Future<void> unlock({
    required ContentType contentType,
    required String targetId,
  }) async {
    emit(state.copyWith(isUnlocking: true, error: null));

    try {
      final result = await _repository.unlock(
        contentType: contentType,
        targetId: targetId,
      );

      // Update points balance using copyWith
      di.sl<AuthCubit>().updatePoints(result.pointsBalance);

      // Update the state based on content type
      if (contentType == ContentType.profileContact) {
        // Update the profile in the list
        final updatedProfiles = state.profiles.map((profile) {
          if (profile.id == targetId) {
            return profile.copyWith(isSeen: true);
          }
          return profile;
        }).toList();

        emit(
          state.copyWith(
            isUnlocking: false,
            profiles: updatedProfiles,
            error: null,
          ),
        );
      } else {
        // For analysis types, update the market exploration
        final updatedExploration = state.marketExploration?.copyWith(
          competitiveAnalysis: contentType == ContentType.competitiveAnalysis
              ? state.marketExploration?.competitiveAnalysis?.copyWith(
                  isSeen: true,
                )
              : state.marketExploration?.competitiveAnalysis,
          pestleAnalysis: contentType == ContentType.pestleAnalysis
              ? state.marketExploration?.pestleAnalysis?.copyWith(
                  isSeen: true,
                )
              : state.marketExploration?.pestleAnalysis,
          swotAnalysis: contentType == ContentType.swotAnalysis
              ? state.marketExploration?.swotAnalysis?.copyWith(
                  isSeen: true,
                )
              : state.marketExploration?.swotAnalysis,
          marketPlan: contentType == ContentType.marketPlan
              ? state.marketExploration?.marketPlan?.copyWith(
                  isSeen: true,
                )
              : state.marketExploration?.marketPlan,
        );

        emit(
          state.copyWith(
            isUnlocking: false,
            marketExploration: updatedExploration ?? state.marketExploration,
            error: null,
          ),
        );
      }
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

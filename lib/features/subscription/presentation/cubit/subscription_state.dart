import '../../data/models/profile_model.dart';
import '../../data/models/unlock_item_model.dart';
import '../../data/models/market_exploration_response_model.dart';
import '../../data/models/subscription_model.dart';

class SubscriptionState {
  final bool isLoading;
  final bool isUnlocking;
  final MarketExplorationResponseModel? marketExploration;
  final List<ProfileModel> profiles;
  final List<UnlockItemModel> unlocks;
  final List<SubscriptionModel> subscriptions;
  final int unlocksTotalPages;
  final int unlocksCurrentPage;
  final String? error;

  const SubscriptionState({
    this.isLoading = false,
    this.isUnlocking = false,
    this.marketExploration,
    this.profiles = const [],
    this.unlocks = const [],
    this.subscriptions = const [],
    this.unlocksTotalPages = 0,
    this.unlocksCurrentPage = 1,
    this.error,
  });

  const SubscriptionState.initial()
    : isLoading = false,
      isUnlocking = false,
      marketExploration = null,
      profiles = const [],
      unlocks = const [],
      subscriptions = const [],
      unlocksTotalPages = 0,
      unlocksCurrentPage = 1,
      error = null;

  const SubscriptionState.loading()
    : isLoading = true,
      isUnlocking = false,
      marketExploration = null,
      profiles = const [],
      unlocks = const [],
      subscriptions = const [],
      unlocksTotalPages = 0,
      unlocksCurrentPage = 1,
      error = null;

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isUnlocking,
    MarketExplorationResponseModel? marketExploration,
    List<ProfileModel>? profiles,
    List<UnlockItemModel>? unlocks,
    List<SubscriptionModel>? subscriptions,
    int? unlocksTotalPages,
    int? unlocksCurrentPage,
    String? error,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isUnlocking: isUnlocking ?? this.isUnlocking,
      marketExploration: marketExploration ?? this.marketExploration,
      profiles: profiles ?? this.profiles,
      unlocks: unlocks ?? this.unlocks,
      subscriptions: subscriptions ?? this.subscriptions,
      unlocksTotalPages: unlocksTotalPages ?? this.unlocksTotalPages,
      unlocksCurrentPage: unlocksCurrentPage ?? this.unlocksCurrentPage,
      error: error ?? this.error,
    );
  }
}

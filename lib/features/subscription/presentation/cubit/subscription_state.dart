import '../../data/models/profile_model.dart';
import '../../data/models/unlock_item_model.dart';
import '../../data/models/market_exploration_response_model.dart';

class SubscriptionState {
  final bool isLoading;
  final bool isUnlocking;
  final MarketExplorationResponseModel? marketExploration;
  final List<ProfileModel> profiles;
  final List<UnlockItemModel> unlocks;
  final int unlocksTotalPages;
  final int unlocksCurrentPage;
  final String? error;

  const SubscriptionState({
    this.isLoading = false,
    this.isUnlocking = false,
    this.marketExploration,
    this.profiles = const [],
    this.unlocks = const [],
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
      unlocksTotalPages = 0,
      unlocksCurrentPage = 1,
      error = null;

  const SubscriptionState.loading()
    : isLoading = true,
      isUnlocking = false,
      marketExploration = null,
      profiles = const [],
      unlocks = const [],
      unlocksTotalPages = 0,
      unlocksCurrentPage = 1,
      error = null;

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isUnlocking,
    MarketExplorationResponseModel? marketExploration,
    List<ProfileModel>? profiles,
    List<UnlockItemModel>? unlocks,
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
      unlocksTotalPages: unlocksTotalPages ?? this.unlocksTotalPages,
      unlocksCurrentPage: unlocksCurrentPage ?? this.unlocksCurrentPage,
      error: error ?? this.error,
    );
  }
}

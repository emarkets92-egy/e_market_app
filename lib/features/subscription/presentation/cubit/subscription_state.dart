import '../../data/models/profile_model.dart';
import '../../data/models/unlock_item_model.dart';
import '../../data/models/market_exploration_response_model.dart';
import '../../data/models/subscription_model.dart';

class SubscriptionState {
  final bool isLoading;
  final bool isUnlocking;
  final MarketExplorationResponseModel? marketExploration;
  final List<ProfileModel> unseenProfiles;
  final List<ProfileModel> seenProfiles;
  final int unseenProfilesPage;
  final int unseenProfilesLimit;
  final int unseenProfilesTotal;
  final int unseenProfilesTotalPages;
  final int seenProfilesPage;
  final int seenProfilesLimit;
  final int seenProfilesTotal;
  final int seenProfilesTotalPages;
  final List<UnlockItemModel> unlocks;
  final List<SubscriptionModel> subscriptions;
  final int unlocksTotalPages;
  final int unlocksCurrentPage;
  final String? error;

  const SubscriptionState({
    this.isLoading = false,
    this.isUnlocking = false,
    this.marketExploration,
    this.unseenProfiles = const [],
    this.seenProfiles = const [],
    this.unseenProfilesPage = 1,
    this.unseenProfilesLimit = 20,
    this.unseenProfilesTotal = 0,
    this.unseenProfilesTotalPages = 0,
    this.seenProfilesPage = 1,
    this.seenProfilesLimit = 20,
    this.seenProfilesTotal = 0,
    this.seenProfilesTotalPages = 0,
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
      unseenProfiles = const [],
      seenProfiles = const [],
      unseenProfilesPage = 1,
      unseenProfilesLimit = 20,
      unseenProfilesTotal = 0,
      unseenProfilesTotalPages = 0,
      seenProfilesPage = 1,
      seenProfilesLimit = 20,
      seenProfilesTotal = 0,
      seenProfilesTotalPages = 0,
      unlocks = const [],
      subscriptions = const [],
      unlocksTotalPages = 0,
      unlocksCurrentPage = 1,
      error = null;

  const SubscriptionState.loading()
    : isLoading = true,
      isUnlocking = false,
      marketExploration = null,
      unseenProfiles = const [],
      seenProfiles = const [],
      unseenProfilesPage = 1,
      unseenProfilesLimit = 20,
      unseenProfilesTotal = 0,
      unseenProfilesTotalPages = 0,
      seenProfilesPage = 1,
      seenProfilesLimit = 20,
      seenProfilesTotal = 0,
      seenProfilesTotalPages = 0,
      unlocks = const [],
      subscriptions = const [],
      unlocksTotalPages = 0,
      unlocksCurrentPage = 1,
      error = null;

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isUnlocking,
    MarketExplorationResponseModel? marketExploration,
    List<ProfileModel>? unseenProfiles,
    List<ProfileModel>? seenProfiles,
    int? unseenProfilesPage,
    int? unseenProfilesLimit,
    int? unseenProfilesTotal,
    int? unseenProfilesTotalPages,
    int? seenProfilesPage,
    int? seenProfilesLimit,
    int? seenProfilesTotal,
    int? seenProfilesTotalPages,
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
      unseenProfiles: unseenProfiles ?? this.unseenProfiles,
      seenProfiles: seenProfiles ?? this.seenProfiles,
      unseenProfilesPage: unseenProfilesPage ?? this.unseenProfilesPage,
      unseenProfilesLimit: unseenProfilesLimit ?? this.unseenProfilesLimit,
      unseenProfilesTotal: unseenProfilesTotal ?? this.unseenProfilesTotal,
      unseenProfilesTotalPages:
          unseenProfilesTotalPages ?? this.unseenProfilesTotalPages,
      seenProfilesPage: seenProfilesPage ?? this.seenProfilesPage,
      seenProfilesLimit: seenProfilesLimit ?? this.seenProfilesLimit,
      seenProfilesTotal: seenProfilesTotal ?? this.seenProfilesTotal,
      seenProfilesTotalPages:
          seenProfilesTotalPages ?? this.seenProfilesTotalPages,
      unlocks: unlocks ?? this.unlocks,
      subscriptions: subscriptions ?? this.subscriptions,
      unlocksTotalPages: unlocksTotalPages ?? this.unlocksTotalPages,
      unlocksCurrentPage: unlocksCurrentPage ?? this.unlocksCurrentPage,
      error: error ?? this.error,
    );
  }
}

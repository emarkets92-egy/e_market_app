import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../cubit/subscription_state.dart';
import '../../data/models/explore_market_request_model.dart';
import '../../data/models/unlock_item_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/analysis_models.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/presentation/cubit/auth_cubit.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionRepository _repository;
  
  // Store last exploreMarket parameters to refresh after unlock
  String? _lastProductId;
  String? _lastMarketType;
  int? _lastCountryId;

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
    int? unseenPage,
    int? unseenLimit,
    int? seenPage,
    int? seenLimit,
  }) async {
    // Store parameters for later use (e.g., refreshing after unlock)
    _lastProductId = productId;
    _lastMarketType = marketType;
    _lastCountryId = countryId;
    
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final request = ExploreMarketRequestModel(
        productId: productId,
        marketType: marketType,
        countryId: countryId,
        unseenPage: unseenPage ?? state.unseenProfilesPage,
        unseenLimit: unseenLimit ?? state.unseenProfilesLimit,
        seenPage: seenPage ?? state.seenProfilesPage,
        seenLimit: seenLimit ?? state.seenProfilesLimit,
      );
      final result = await _repository.exploreMarket(request);

      // Log the parsed result to debug missing analysis data
      print('✅ exploreMarket result parsed successfully');
      print(
        '  - competitiveAnalysis: ${result.competitiveAnalysis != null ? "✅" : "❌"}',
      );
      print('  - pestleAnalysis: ${result.pestleAnalysis != null ? "✅" : "❌"}');
      print('  - swotAnalysis: ${result.swotAnalysis != null ? "✅" : "❌"}');
      print('  - marketPlan: ${result.marketPlan != null ? "✅" : "❌"}');

      // Warn if analysis data is missing
      if (result.competitiveAnalysis == null &&
          result.pestleAnalysis == null &&
          result.swotAnalysis == null &&
          result.marketPlan == null) {
        print('⚠️ WARNING: All analysis data is missing from API response!');
      }

      emit(
        state.copyWith(
          isLoading: false,
          marketExploration: result,
          unseenProfiles: result.unseenProfiles?.data ?? [],
          seenProfiles: result.seenProfiles?.data ?? [],
          unseenProfilesPage:
              result.unseenProfiles?.pagination.page ??
              state.unseenProfilesPage,
          unseenProfilesLimit:
              result.unseenProfiles?.pagination.limit ??
              state.unseenProfilesLimit,
          unseenProfilesTotal: result.unseenProfiles?.pagination.total ?? 0,
          unseenProfilesTotalPages:
              result.unseenProfiles?.pagination.totalPages ?? 0,
          seenProfilesPage:
              result.seenProfiles?.pagination.page ?? state.seenProfilesPage,
          seenProfilesLimit:
              result.seenProfiles?.pagination.limit ?? state.seenProfilesLimit,
          seenProfilesTotal: result.seenProfiles?.pagination.total ?? 0,
          seenProfilesTotalPages:
              result.seenProfiles?.pagination.totalPages ?? 0,
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
    emit(state.copyWith(isUnlocking: true, error: null, successMessage: null));

    try {
      final result = await _repository.unlock(
        contentType: contentType,
        targetId: targetId,
      );

      // Update points balance using copyWith
      di.sl<AuthCubit>().updatePoints(result.pointsBalance);

      // If unlocked content data is available, use it to update state
      if (result.data != null && result.data!.contentData != null) {
        // Update the state based on content type with actual unlocked data
        if (contentType == ContentType.profileContact &&
            result.data!.contentData is ProfileModel) {
          // Check if profile is in unseen list
          final isInUnseen = state.unseenProfiles.any(
            (profile) => profile.id == targetId,
          );

          if (isInUnseen) {
            // Remove from unseen
            final updatedUnseenProfiles = state.unseenProfiles
                .where((profile) => profile.id != targetId)
                .toList();

            emit(
              state.copyWith(
                isUnlocking: false,
                unseenProfiles: updatedUnseenProfiles,
                unseenProfilesTotal: (state.unseenProfilesTotal - 1)
                    .clamp(0, double.infinity)
                    .toInt(),
                successMessage: 'Profile unlocked successfully!',
                error: null,
              ),
            );

            // Refresh seen profiles from page 1 to show newly unlocked item at the top
            // (backend sorts by unlockedAt DESC, so new items appear first)
            if (_lastProductId != null && _lastMarketType != null && _lastCountryId != null) {
              await exploreMarket(
                productId: _lastProductId!,
                marketType: _lastMarketType!,
                countryId: _lastCountryId!,
                seenPage: 1, // Reset to page 1 to see newly unlocked item
                // Keep current unseen page to maintain position
                unseenPage: state.unseenProfilesPage,
              );
            }
          } else {
            // Profile is already in seen list, refresh from page 1 to update order
            if (_lastProductId != null && _lastMarketType != null && _lastCountryId != null) {
              await exploreMarket(
                productId: _lastProductId!,
                marketType: _lastMarketType!,
                countryId: _lastCountryId!,
                seenPage: 1, // Reset to page 1 to see updated order
                // Keep current unseen page to maintain position
                unseenPage: state.unseenProfilesPage,
              );
            } else {
              emit(
                state.copyWith(
                  isUnlocking: false,
                  error: null,
                ),
              );
            }
          }
        } else if (contentType == ContentType.competitiveAnalysis &&
            result.data!.contentData is CompetitiveAnalysisModel) {
          // Update competitive analysis with unlocked data
          final unlockedAnalysis =
              result.data!.contentData as CompetitiveAnalysisModel;
          final updatedExploration = state.marketExploration?.copyWith(
            competitiveAnalysis: unlockedAnalysis,
          );

          emit(
            state.copyWith(
              isUnlocking: false,
              marketExploration: updatedExploration ?? state.marketExploration,
              error: null,
            ),
          );
        } else if (contentType == ContentType.pestleAnalysis &&
            result.data!.contentData is PESTLEAnalysisModel) {
          // Update PESTLE analysis with unlocked data
          final unlockedAnalysis =
              result.data!.contentData as PESTLEAnalysisModel;
          final updatedExploration = state.marketExploration?.copyWith(
            pestleAnalysis: unlockedAnalysis,
          );

          emit(
            state.copyWith(
              isUnlocking: false,
              marketExploration: updatedExploration ?? state.marketExploration,
              error: null,
            ),
          );
        } else if (contentType == ContentType.swotAnalysis &&
            result.data!.contentData is SWOTAnalysisModel) {
          // Update SWOT analysis with unlocked data
          final unlockedAnalysis =
              result.data!.contentData as SWOTAnalysisModel;
          final updatedExploration = state.marketExploration?.copyWith(
            swotAnalysis: unlockedAnalysis,
          );

          emit(
            state.copyWith(
              isUnlocking: false,
              marketExploration: updatedExploration ?? state.marketExploration,
              error: null,
            ),
          );
        } else if (contentType == ContentType.marketPlan &&
            result.data!.contentData is MarketPlanModel) {
          // Update market plan with unlocked data
          final unlockedPlan = result.data!.contentData as MarketPlanModel;
          final updatedExploration = state.marketExploration?.copyWith(
            marketPlan: unlockedPlan,
          );

          emit(
            state.copyWith(
              isUnlocking: false,
              marketExploration: updatedExploration ?? state.marketExploration,
              error: null,
            ),
          );
        } else {
          // Fallback: just set isSeen if data structure doesn't match
          emit(state.copyWith(isUnlocking: false, error: null));
        }
        } else if (contentType == ContentType.shipmentRecords) {
          // Handle shipment record unlock
          final isInUnseen = state.unseenShipmentRecords.any(
            (record) => record.id == targetId,
          );

          if (isInUnseen) {
            // Remove from unseen
            final updatedUnseenRecords = state.unseenShipmentRecords
                .where((record) => record.id != targetId)
                .toList();

            emit(
              state.copyWith(
                isUnlocking: false,
                unseenShipmentRecords: updatedUnseenRecords,
                unseenShipmentRecordsTotal:
                    (state.unseenShipmentRecordsTotal - 1)
                        .clamp(0, double.infinity)
                        .toInt(),
                successMessage: 'Shipment record unlocked successfully!',
                error: null,
              ),
            );

            // Refresh shipment records from page 1 to show newly unlocked item at the top
            // (backend sorts by unlockedAt DESC, so new items appear first)
            if (state.currentProfileId != null) {
              await getShipmentRecords(
                profileId: state.currentProfileId!,
                seenPage: 1, // Reset to page 1 to see newly unlocked item
              );
            }
          } else {
            // Record is already in seen list, refresh from page 1 to update order
            if (state.currentProfileId != null) {
              await getShipmentRecords(
                profileId: state.currentProfileId!,
                seenPage: 1, // Reset to page 1 to see updated order
              );
            } else {
              emit(
                state.copyWith(
                  isUnlocking: false,
                  error: null,
                ),
              );
            }
          }
        } else {
          // Fallback: if no data returned, just update isSeen flag (backward compatibility)
          if (contentType == ContentType.profileContact) {
          ProfileModel? profileInUnseen;
          try {
            profileInUnseen = state.unseenProfiles.firstWhere(
              (profile) => profile.id == targetId,
            );
          } catch (e) {
            profileInUnseen = null;
          }

          if (profileInUnseen != null) {
            final updatedUnseenProfiles = state.unseenProfiles
                .where((profile) => profile.id != targetId)
                .toList();

            final unlockedProfile = profileInUnseen.copyWith(isSeen: true);
            final updatedSeenProfiles = [
              ...state.seenProfiles,
              unlockedProfile,
            ];

            emit(
              state.copyWith(
                isUnlocking: false,
                unseenProfiles: updatedUnseenProfiles,
                seenProfiles: updatedSeenProfiles,
                unseenProfilesTotal: (state.unseenProfilesTotal - 1)
                    .clamp(0, double.infinity)
                    .toInt(),
                seenProfilesTotal: state.seenProfilesTotal + 1,
                successMessage: 'Profile unlocked successfully!',
                error: null,
              ),
            );
          } else {
            final updatedSeenProfiles = state.seenProfiles.map((profile) {
              if (profile.id == targetId) {
                return profile.copyWith(isSeen: true);
              }
              return profile;
            }).toList();

            emit(
              state.copyWith(
                isUnlocking: false,
                seenProfiles: updatedSeenProfiles,
                error: null,
              ),
            );
          }
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
                ? state.marketExploration?.swotAnalysis?.copyWith(isSeen: true)
                : state.marketExploration?.swotAnalysis,
            marketPlan: contentType == ContentType.marketPlan
                ? state.marketExploration?.marketPlan?.copyWith(isSeen: true)
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
      }
    } catch (e) {
      emit(state.copyWith(isUnlocking: false, error: e.toString()));
    }
  }

  Future<void> getShipmentRecords({
    required String profileId,
    int? seenPage,
    int? seenLimit,
    int? unseenPage,
    int? unseenLimit,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await _repository.getShipmentRecords(
        profileId: profileId,
        seenPage: seenPage ?? state.seenShipmentRecordsPage,
        seenLimit: seenLimit ?? state.seenShipmentRecordsLimit,
        unseenPage: unseenPage ?? state.unseenShipmentRecordsPage,
        unseenLimit: unseenLimit ?? state.unseenShipmentRecordsLimit,
      );

      emit(
        state.copyWith(
          isLoading: false,
          seenShipmentRecords: result.seenShipmentRecords?.data ?? [],
          unseenShipmentRecords: result.unseenShipmentRecords?.data ?? [],
          seenShipmentRecordsPage:
              result.seenShipmentRecords?.pagination.page ??
              state.seenShipmentRecordsPage,
          seenShipmentRecordsLimit:
              result.seenShipmentRecords?.pagination.limit ??
              state.seenShipmentRecordsLimit,
          seenShipmentRecordsTotal:
              result.seenShipmentRecords?.pagination.total ?? 0,
          seenShipmentRecordsTotalPages:
              result.seenShipmentRecords?.pagination.totalPages ?? 0,
          unseenShipmentRecordsPage:
              result.unseenShipmentRecords?.pagination.page ??
              state.unseenShipmentRecordsPage,
          unseenShipmentRecordsLimit:
              result.unseenShipmentRecords?.pagination.limit ??
              state.unseenShipmentRecordsLimit,
          unseenShipmentRecordsTotal:
              result.unseenShipmentRecords?.pagination.total ?? 0,
          unseenShipmentRecordsTotalPages:
              result.unseenShipmentRecords?.pagination.totalPages ?? 0,
          shipmentRecordsUnlockCost: result.unlockCost,
          currentProfileId: profileId,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void clearSuccessMessage() {
    if (!isClosed) {
      emit(state.copyWith(successMessage: null));
    }
  }
}

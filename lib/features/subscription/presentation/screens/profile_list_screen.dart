import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../widgets/profile_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../data/models/unlock_item_model.dart';

class ProfileListScreen extends StatefulWidget {
  final String productId;
  final int countryId;
  final String marketType;

  const ProfileListScreen({
    super.key,
    required this.productId,
    required this.countryId,
    required this.marketType,
  });

  @override
  State<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _lastShownSuccessMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Note: exploreMarket is now called in MarketSelectionScreen
    // Only call it here if data is not already loaded
    // This prevents unnecessary API calls when navigating from MarketSelectionScreen
    final currentState = di.sl<SubscriptionCubit>().state;

    // Only load if marketExploration is null (not loaded yet)
    // This handles direct navigation to ProfileListScreen without going through MarketSelectionScreen
    if (currentState.marketExploration == null) {
      di.sl<SubscriptionCubit>().exploreMarket(
        productId: widget.productId,
        marketType: widget.marketType,
        countryId: widget.countryId,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUnseenProfiles(int page) {
    di.sl<SubscriptionCubit>().exploreMarket(
      productId: widget.productId,
      marketType: widget.marketType,
      countryId: widget.countryId,
      unseenPage: page,
    );
  }

  void _loadSeenProfiles(int page) {
    di.sl<SubscriptionCubit>().exploreMarket(
      productId: widget.productId,
      marketType: widget.marketType,
      countryId: widget.countryId,
      seenPage: page,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
            bloc: di.sl<SubscriptionCubit>(),
            builder: (context, state) {
              return TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    text:
                        'New Profiles${state.unseenProfilesTotal > 0 ? ' (${state.unseenProfilesTotal})' : ''}',
                  ),
                  Tab(
                    text:
                        'Unlocked${state.seenProfilesTotal > 0 ? ' (${state.seenProfilesTotal})' : ''}',
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        bloc: di.sl<SubscriptionCubit>(),
        listener: (context, state) {
          // Only show snackbar if this is a new success message we haven't shown yet
          if (state.successMessage != null &&
              state.successMessage != _lastShownSuccessMessage) {
            _lastShownSuccessMessage = state.successMessage;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            // Clear the success message after showing using post-frame callback
            // to avoid triggering listener again immediately
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                di.sl<SubscriptionCubit>().clearSuccessMessage();
              } catch (e) {
                // Ignore errors if cubit is disposed
              }
            });
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading &&
              state.unseenProfiles.isEmpty &&
              state.seenProfiles.isEmpty) {
            return const LoadingIndicator();
          }

          if (state.error != null &&
              state.unseenProfiles.isEmpty &&
              state.seenProfiles.isEmpty) {
            return AppErrorWidget(
              message: state.error!,
              onRetry: () {
                di.sl<SubscriptionCubit>().exploreMarket(
                  productId: widget.productId,
                  marketType: widget.marketType,
                  countryId: widget.countryId,
                );
              },
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: New Profiles (Unseen)
              _buildProfileList(
                context: context,
                profiles: state.unseenProfiles,
                isLoading: state.isLoading,
                currentPage: state.unseenProfilesPage,
                totalPages: state.unseenProfilesTotalPages,
                onPageChanged: _loadUnseenProfiles,
                isUnlocking: state.isUnlocking,
              ),
              // Tab 2: Unlocked Profiles (Seen)
              _buildProfileList(
                context: context,
                profiles: state.seenProfiles,
                isLoading: state.isLoading,
                currentPage: state.seenProfilesPage,
                totalPages: state.seenProfilesTotalPages,
                onPageChanged: _loadSeenProfiles,
                isUnlocking: state.isUnlocking,
                isSeen: true,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileList({
    required BuildContext context,
    required List profiles,
    required bool isLoading,
    required int currentPage,
    required int totalPages,
    required Function(int) onPageChanged,
    required bool isUnlocking,
    bool isSeen = false,
  }) {
    if (profiles.isEmpty && !isLoading) {
      // Check if there are more pages before showing "No profiles found"
      // Only for new profiles (unseen), not for unlocked profiles
      if (!isSeen && totalPages > 1 && currentPage < totalPages) {
        // Load next page if available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onPageChanged(currentPage + 1);
        });
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Text(
          isSeen ? 'No unlocked profiles found' : 'No new profiles found',
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return ProfileCard(
                profile: profile,
                isUnlocking: isUnlocking,
                onUnlock: isSeen
                    ? () {} // Dummy callback for seen profiles
                    : () {
                        di.sl<SubscriptionCubit>().unlock(
                          contentType: ContentType.profileContact,
                          targetId: profile.id,
                        );
                      },
              );
            },
          ),
        ),
        if (totalPages > 1)
          _buildPaginationControls(
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: onPageChanged,
          ),
      ],
    );
  }

  Widget _buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required Function(int) onPageChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1
                ? () => onPageChanged(currentPage - 1)
                : null,
          ),
          Text('Page $currentPage of $totalPages'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

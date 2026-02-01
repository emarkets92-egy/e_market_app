import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../widgets/profile_card.dart';
import '../widgets/profile_table_row.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/premium_header_bar.dart';
import '../../data/models/unlock_item_model.dart';
import '../../data/models/profile_model.dart';

class ProfileListScreen extends StatefulWidget {
  final String productId;
  final int countryId;
  final String marketType;

  const ProfileListScreen({super.key, required this.productId, required this.countryId, required this.marketType});

  @override
  State<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _lastShownSuccessMessage;
  bool _isTableView = false; // false = card view, true = table view (default: card)

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
      di.sl<SubscriptionCubit>().exploreMarket(productId: widget.productId, marketType: widget.marketType, countryId: widget.countryId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUnseenProfiles(int page) {
    di.sl<SubscriptionCubit>().exploreMarket(productId: widget.productId, marketType: widget.marketType, countryId: widget.countryId, unseenPage: page);
  }

  void _loadSeenProfiles(int page) {
    di.sl<SubscriptionCubit>().exploreMarket(productId: widget.productId, marketType: widget.marketType, countryId: widget.countryId, seenPage: page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Premium Header Bar
          const PremiumHeaderBar(showBackButton: true),
          // Tab Bar
          BlocBuilder<SubscriptionCubit, SubscriptionState>(
            bloc: di.sl<SubscriptionCubit>(),
            builder: (context, state) {
              return Container(
                color: Colors.white,
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: '${'new_profiles'.tr()}${state.unseenProfilesTotal > 0 ? ' (${state.unseenProfilesTotal})' : ''}'),
                        Tab(text: '${'unlocked'.tr()}${state.seenProfilesTotal > 0 ? ' (${state.seenProfilesTotal})' : ''}'),
                      ],
                    ),
                    // View Toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('importers_directory'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              Text('results_count'.tr(namedArgs: {'count': (state.unseenProfilesTotal + state.seenProfilesTotal).toString()}), style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              const SizedBox(width: 16),
                              // View Toggle Icons
                              Container(
                                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildViewToggleButton(icon: Icons.view_list, isSelected: _isTableView, onTap: () => setState(() => _isTableView = true)),
                                    _buildViewToggleButton(icon: Icons.grid_view, isSelected: !_isTableView, onTap: () => setState(() => _isTableView = false)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Main Content
          Expanded(
            child: BlocConsumer<SubscriptionCubit, SubscriptionState>(
              bloc: di.sl<SubscriptionCubit>(),
              listener: (context, state) {
                // Only show snackbar if this is a new success message we haven't shown yet
                if (state.successMessage != null && state.successMessage != _lastShownSuccessMessage) {
                  _lastShownSuccessMessage = state.successMessage;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.successMessage!), backgroundColor: Colors.green, duration: const Duration(seconds: 2)));
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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
                }
              },
              builder: (context, state) {
                if (state.isLoading && state.unseenProfiles.isEmpty && state.seenProfiles.isEmpty) {
                  return const LoadingIndicator();
                }

                if (state.error != null && state.unseenProfiles.isEmpty && state.seenProfiles.isEmpty) {
                  return AppErrorWidget(
                    message: state.error!,
                    onRetry: () {
                      di.sl<SubscriptionCubit>().exploreMarket(productId: widget.productId, marketType: widget.marketType, countryId: widget.countryId);
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
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: isSelected ? Colors.blue : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: isSelected ? Colors.white : Colors.grey[600], size: 20),
      ),
    );
  }

  Widget _buildProfileList({
    required BuildContext context,
    required List<ProfileModel> profiles,
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
      return Center(child: Text(isSeen ? 'no_unlocked_profiles_found'.tr() : 'no_new_profiles_found'.tr()));
    }

    return Column(
      children: [
        Expanded(
          child: _isTableView
              ? _buildTableView(profiles: profiles, isUnlocking: isUnlocking, isSeen: isSeen)
              : _buildGridView(context: context, profiles: profiles, isUnlocking: isUnlocking, isSeen: isSeen),
        ),
        if (totalPages > 1) _buildPaginationControls(currentPage: currentPage, totalPages: totalPages, onPageChanged: onPageChanged),
      ],
    );
  }

  Widget _buildGridView({required BuildContext context, required List<ProfileModel> profiles, required bool isUnlocking, required bool isSeen}) {
    // Calculate number of columns based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 800 ? 3 : 2;

    // Use a larger aspect ratio to make cards wider and take less vertical space
    // Higher aspect ratio = wider cards relative to height = less vertical space
    final childAspectRatio = screenWidth > 800 ? 1.5 : 1.3;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return ProfileCard(
          profile: profile,
          isUnlocking: isUnlocking,
          onUnlock: isSeen
              ? () {} // Dummy callback for seen profiles
              : () {
                  di.sl<SubscriptionCubit>().unlock(contentType: ContentType.profileContact, targetId: profile.id);
                },
        );
      },
    );
  }

  List<String> _getVisibleColumns(List<ProfileModel> profiles) {
    final columns = <String>[];
    
    // Always show profile and name
    columns.add('profile');
    columns.add('name');
    
    // Check if any profile has email
    if (profiles.any((p) => p.email != null && p.email!.isNotEmpty)) {
      columns.add('email');
    }
    
    // Check if any profile has whatsapp
    if (profiles.any((p) => p.whatsapp != null && p.whatsapp!.isNotEmpty)) {
      columns.add('whatsapp');
    }
    
    return columns;
  }

  Widget _buildTableView({required List<ProfileModel> profiles, required bool isUnlocking, required bool isSeen}) {
    final visibleColumns = _getVisibleColumns(profiles);
    final scrollController = ScrollController();
    
    final columnWidths = {
      'profile': 80.0,
      'name': 200.0,
      'email': 200.0,
      'whatsapp': 150.0,
    };

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: visibleColumns.map((column) {
                  final width = columnWidths[column] ?? 150.0;
                  String label = '';
                  
                  switch (column) {
                    case 'profile':
                      label = 'profile'.tr().toUpperCase();
                      break;
                    case 'name':
                      label = 'importer_name'.tr().toUpperCase();
                      break;
                    case 'email':
                      label = 'email'.tr().toUpperCase();
                      break;
                    case 'whatsapp':
                      label = 'whatsapp'.tr().toUpperCase();
                      break;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: width,
                      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Table Rows
            ...profiles.map((profile) {
              return ProfileTableRow(
                profile: profile,
                isUnlocking: isUnlocking,
                visibleColumns: visibleColumns,
                onUnlock: isSeen
                    ? () {}
                    : () {
                        di.sl<SubscriptionCubit>().unlock(contentType: ContentType.profileContact, targetId: profile.id);
                      },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls({required int currentPage, required int totalPages, required Function(int) onPageChanged}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null),
          Text('page_of'.tr(namedArgs: {'current': currentPage.toString(), 'total': totalPages.toString()})),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null),
        ],
      ),
    );
  }
}

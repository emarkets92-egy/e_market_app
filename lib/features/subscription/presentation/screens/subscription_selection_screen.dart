import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/premium_header_bar.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../../data/models/subscription_model.dart';
import '../../../../features/localization/data/models/country_model.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/unlock_item_model.dart';
import '../widgets/subscription_profile_table_row.dart';
import '../widgets/subscription_profile_card.dart';

class SubscriptionSelectionScreen extends StatefulWidget {
  const SubscriptionSelectionScreen({super.key});

  @override
  State<SubscriptionSelectionScreen> createState() => _SubscriptionSelectionScreenState();
}

class _SubscriptionSelectionScreenState extends State<SubscriptionSelectionScreen> {
  SubscriptionModel? _selectedProduct;
  String? _selectedMarketType;
  CountryModel? _selectedCountry; // This maps to "Import Country"
  String _selectedViewType = 'new'; // 'new' or 'unlocked'
  bool _isTableView = true; // false = card view, true = table view (default: table)
  String? _lastShownSuccessMessage; // Track last shown success message to avoid duplicate dialogs

  @override
  void initState() {
    super.initState();
    di.sl<SubscriptionCubit>().getSubscriptions(activeOnly: true);
  }

  /// Resolves the API market type. For 'both', picks targetMarkets or otherMarkets
  /// based on the selected country. Returns null if product, market type, or country is missing.
  String? _getResolvedMarketType() {
    if (_selectedProduct == null || _selectedMarketType == null || _selectedCountry == null) return null;
    if (_selectedMarketType != 'both') return _selectedMarketType;
    final targetMarkets = _selectedProduct!.targetMarkets ?? [];
    final otherMarkets = _selectedProduct!.otherMarkets ?? [];
    if (targetMarkets.any((c) => c.id == _selectedCountry!.id)) return AppConstants.marketTypeTarget;
    if (otherMarkets.any((c) => c.id == _selectedCountry!.id)) return AppConstants.marketTypeOther;
    return AppConstants.marketTypeTarget;
  }

  void _onSelectionChanged() {
    final marketTypeToUse = _getResolvedMarketType();
    if (marketTypeToUse != null) {
      di.sl<SubscriptionCubit>().exploreMarket(
        productId: _selectedProduct!.productId,
        marketType: marketTypeToUse,
        countryId: _selectedCountry!.id,
        unseenPage: 1, // Reset to page 1 on new filter
        seenPage: 1,
      );
    }
  }

  List<CountryModel> _getAvailableCountries() {
    if (_selectedProduct == null || _selectedMarketType == null) {
      return [];
    }

    if (_selectedMarketType == 'both') {
      final target = _selectedProduct!.targetMarkets ?? [];
      final other = _selectedProduct!.otherMarkets ?? [];
      final combined = [...target, ...other];
      final uniqueCountries = <int, CountryModel>{};
      for (var country in combined) {
        uniqueCountries[country.id] = country;
      }
      return uniqueCountries.values.toList();
    } else if (_selectedMarketType == AppConstants.marketTypeTarget) {
      return _selectedProduct!.targetMarkets ?? [];
    } else if (_selectedMarketType == AppConstants.marketTypeOther) {
      return _selectedProduct!.otherMarkets ?? [];
    } else if (_selectedMarketType == AppConstants.marketTypeImporter) {
      return _selectedProduct!.importerMarkets ?? [];
    }

    return [];
  }

  bool _isExporter(BuildContext context) {
    try {
      final userTypeId = context.read<AuthCubit>().state.user?.userTypeId;
      return userTypeId == AppConstants.userTypeExporter;
    } catch (e) {
      return true;
    }
  }

  List<String> _getAvailableMarketTypes(BuildContext context) {
    if (_selectedProduct == null) {
      return [];
    }

    final hasTarget = (_selectedProduct!.targetMarkets?.isNotEmpty ?? false);
    final hasOther = (_selectedProduct!.otherMarkets?.isNotEmpty ?? false);
    final hasImporter = (_selectedProduct!.importerMarkets?.isNotEmpty ?? false);

    final types = <String>[];
    final isExporter = _isExporter(context);

    if (isExporter) {
      if (hasTarget) types.add(AppConstants.marketTypeTarget);
      if (hasOther) types.add(AppConstants.marketTypeOther);
      if (hasTarget && hasOther) types.add('both');
    } else {
      if (hasImporter) types.add(AppConstants.marketTypeImporter);
    }

    return types;
  }

  String _getMarketTypeLabel(String marketType) {
    switch (marketType) {
      case AppConstants.marketTypeTarget:
        return 'target_market_label'.tr();
      case AppConstants.marketTypeOther:
        return 'other_market'.tr();
      case AppConstants.marketTypeImporter:
        return 'importer_market'.tr();
      case 'both':
        return 'both'.tr();
      default:
        return marketType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light background like in design
      body: Column(
        children: [
          const PremiumHeaderBar(showBackButton: true, showActionButtons: false),
          Expanded(
            child: BlocConsumer<SubscriptionCubit, SubscriptionState>(
              bloc: di.sl<SubscriptionCubit>(),
              listener: (context, state) {
                // Show snackbar for success messages (including profile unlock)
                if (state.successMessage != null && state.successMessage != _lastShownSuccessMessage) {
                  _lastShownSuccessMessage = state.successMessage;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.successMessage!), backgroundColor: Colors.green, duration: const Duration(seconds: 2)));
                  di.sl<SubscriptionCubit>().clearSuccessMessage();
                }
                if (state.error != null && state.marketExploration != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: Colors.red));
                }
              },
              builder: (context, state) {
                if (state.isLoading && state.subscriptions.isEmpty) {
                  return const LoadingIndicator();
                }

                if (state.error != null && state.subscriptions.isEmpty) {
                  return AppErrorWidget(
                    message: state.error!,
                    onRetry: () {
                      di.sl<SubscriptionCubit>().getSubscriptions(activeOnly: true);
                    },
                  );
                }

                // Main Content
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filter Bar
                        _buildFilterBar(context, state.subscriptions),

                        const SizedBox(height: 24),

                        // Results Section
                        if (_selectedProduct != null && _selectedCountry != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'importers_directory'.tr(),
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'results_count'.tr(
                                      namedArgs: {'count': (_selectedViewType == 'new' ? state.unseenProfilesTotal : state.seenProfilesTotal).toString()},
                                    ),
                                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // View Toggle (table ↔ card)
                                  Container(
                                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildViewToggleButton(
                                          icon: Icons.view_list,
                                          isSelected: _isTableView,
                                          onTap: () => setState(() => _isTableView = true),
                                        ),
                                        _buildViewToggleButton(
                                          icon: Icons.grid_view,
                                          isSelected: !_isTableView,
                                          onTap: () => setState(() => _isTableView = false),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // const SizedBox(width: 12),
                                  // // Analysis button
                                  // AppButton(
                                  //   text: 'analysis'.tr(),
                                  //   onPressed: () {
                                  //     context.push('${RouteNames.analysis}?productId=${_selectedProduct!.productId}&countryId=${_selectedCountry!.id}');
                                  //   },
                                  // ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Table Header
                          if (_isTableView) _buildTableHeader(),

                          // Content
                          if (state.isLoading && state.marketExploration == null)
                            const Center(
                              child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()),
                            )
                          else if (_selectedViewType == 'unlocked' && state.seenProfiles.isEmpty)
                            _buildSoonState()
                          else if (_selectedViewType == 'new' && state.unseenProfiles.isEmpty)
                            _buildEmptyState()
                          else
                            _isTableView ? _buildTableContent(state) : _buildGridContent(state),

                          // Pagination
                          _buildPagination(state),
                        ] else ...[
                          // Prompt to select
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 64.0),
                              child: Column(
                                children: [
                                  Icon(Icons.filter_list, size: 48, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('please_select_filters'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, List<SubscriptionModel> subscriptions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout: stack if width is small
          if (constraints.maxWidth < 800) {
            return Column(
              children: [
                _buildDropdownItem(label: 'PRODUCT', child: _buildProductDropdown(subscriptions)),
                const SizedBox(height: 16),
                _buildDropdownItem(label: 'MARKET TYPE', child: _buildMarketTypeDropdown(context)),
                const SizedBox(height: 16),
                _buildDropdownItem(label: 'IMPORT COUNTRY', child: _buildCountryDropdown()),
                const SizedBox(height: 16),
                _buildDropdownItem(label: 'STATUS', child: _buildViewTypeDropdown()),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDropdownItem(label: 'PRODUCT', child: _buildProductDropdown(subscriptions)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownItem(label: 'MARKET TYPE', child: _buildMarketTypeDropdown(context)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownItem(label: 'IMPORT COUNTRY', child: _buildCountryDropdown()),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownItem(label: 'STATUS', child: _buildViewTypeDropdown()),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdownItem({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildProductDropdown(List<SubscriptionModel> subscriptions) {
    // Resolve value from current list: DropdownButton matches by object identity, but
    // subscriptions are new instances after each fetch. Match by productId so the
    // selected item is the one from the current items list.
    SubscriptionModel? resolvedValue;
    if (_selectedProduct != null) {
      final idx = subscriptions.indexWhere((s) => s.productId == _selectedProduct!.productId);
      if (idx >= 0) resolvedValue = subscriptions[idx];
    }

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SubscriptionModel>(
          isExpanded: true,
          value: resolvedValue,
          hint: Text('select_product'.tr(), style: const TextStyle(fontSize: 14)),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
          items: subscriptions.map((subscription) {
            return DropdownMenuItem<SubscriptionModel>(
              value: subscription,
              child: Text(
                subscription.productName,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (SubscriptionModel? value) {
            setState(() {
              _selectedProduct = value;
              _selectedMarketType = null;
              _selectedCountry = null;
            });
            _onSelectionChanged();
          },
        ),
      ),
    );
  }

  Widget _buildMarketTypeDropdown(BuildContext context) {
    final availableTypes = _getAvailableMarketTypes(context);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _selectedProduct == null ? Colors.grey[50] : const Color(0xFFF0F7FF), // Blue tint when active
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _selectedProduct == null ? Colors.grey[300]! : Colors.blue.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedMarketType,
          hint: Text('select_market'.tr(), style: TextStyle(fontSize: 14, color: _selectedProduct == null ? Colors.grey : Colors.blue[700])), // Default hint
          icon: Icon(
            _selectedMarketType == null ? Icons.lock_outline : Icons.keyboard_arrow_down,
            color: _selectedProduct == null ? Colors.grey : Colors.blue,
            size: 20,
          ),
          items: availableTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(_getMarketTypeLabel(type), style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: _selectedProduct == null
              ? null
              : (String? value) {
                  setState(() {
                    _selectedMarketType = value;
                    _selectedCountry = null;
                  });
                  _onSelectionChanged();
                },
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    final availableCountries = _getAvailableCountries();
    final isEnabled = _selectedProduct != null && _selectedMarketType != null;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CountryModel>(
          isExpanded: true,
          value: _selectedCountry,
          hint: Text(
            availableCountries.isEmpty && isEnabled ? 'no_countries'.tr() : 'select_country'.tr(), // Match design default if needed
            style: const TextStyle(fontSize: 14),
          ),
          icon: Icon(Icons.flag_outlined, color: isEnabled ? Colors.blue : Colors.grey, size: 20),
          items: availableCountries.map((country) {
            return DropdownMenuItem<CountryModel>(
              value: country,
              child: Text(country.name, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: isEnabled
              ? (CountryModel? value) {
                  setState(() {
                    _selectedCountry = value;
                  });
                  _onSelectionChanged();
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildViewTypeDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedViewType,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
          items: [
            DropdownMenuItem(
              value: 'new',
              child: Text('new_profiles'.tr(), style: const TextStyle(fontSize: 14)),
            ),
            DropdownMenuItem(
              value: 'unlocked',
              child: Text('unlocked_profiles'.tr(), style: const TextStyle(fontSize: 14)),
            ),
          ],
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                _selectedViewType = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'importer_name'.tr().toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              'email'.tr().toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              'phone'.tr().toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              'website'.tr().toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 160,
            child: Text(
              'actions'.tr().toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableContent(SubscriptionState state) {
    // Show profiles based on selection
    final profiles = _selectedViewType == 'new' ? state.unseenProfiles : state.seenProfiles;

    if (profiles.isEmpty) return _buildEmptyState();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: profiles.map((profile) {
          return SubscriptionProfileTableRow(
            profile: profile,
            isUnlocking: state.unlockingTargetId == profile.id,
            disableUnlockButton: state.isUnlocking,
            onUnlock: () {
              di.sl<SubscriptionCubit>().unlock(contentType: ContentType.profileContact, targetId: profile.id);
            },
          );
        }).toList(),
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

  Widget _buildGridContent(SubscriptionState state) {
    final profiles = _selectedViewType == 'new' ? state.unseenProfiles : state.seenProfiles;
    if (profiles.isEmpty) return _buildEmptyState();

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1100 ? 3 : (screenWidth > 700 ? 2 : 1);
    final childAspectRatio = crossAxisCount == 1 ? 1.9 : 1.55;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return InkWell(
          onTap: () {
            context.push('/profiles/${profile.id}');
          },
          child: SubscriptionProfileCard(
            profile: profile,
            isUnlocking: state.unlockingTargetId == profile.id,
            disableUnlockButton: state.isUnlocking,
            onUnlock: () {
              di.sl<SubscriptionCubit>().unlock(contentType: ContentType.profileContact, targetId: profile.id);
            },
          ),
        );
      },
    );
  }

  Widget _buildSoonState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Text('Soon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600])),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text('no_importers_found'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPagination(SubscriptionState state) {
    final currentPage = _selectedViewType == 'new' ? state.unseenProfilesPage : state.seenProfilesPage;
    final totalPages = _selectedViewType == 'new' ? state.unseenProfilesTotalPages : state.seenProfilesTotalPages;
    final marketTypeToUse = _getResolvedMarketType();

    if (totalPages <= 1 || marketTypeToUse == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: currentPage > 1
                ? () {
                    di.sl<SubscriptionCubit>().exploreMarket(
                      productId: _selectedProduct!.productId,
                      marketType: marketTypeToUse,
                      countryId: _selectedCountry!.id,
                      unseenPage: _selectedViewType == 'new' ? currentPage - 1 : null,
                      seenPage: _selectedViewType == 'unlocked' ? currentPage - 1 : null,
                    );
                  }
                : null,
            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('previous'.tr()),
          ),
          const SizedBox(width: 16),
          Text('page_of'.tr(namedArgs: {'current': currentPage.toString(), 'total': totalPages.toString()})),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: currentPage < totalPages
                ? () {
                    di.sl<SubscriptionCubit>().exploreMarket(
                      productId: _selectedProduct!.productId,
                      marketType: marketTypeToUse,
                      countryId: _selectedCountry!.id,
                      unseenPage: _selectedViewType == 'new' ? currentPage + 1 : null,
                      seenPage: _selectedViewType == 'unlocked' ? currentPage + 1 : null,
                    );
                  }
                : null,
            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('next'.tr()),
          ),
        ],
      ),
    );
  }
}

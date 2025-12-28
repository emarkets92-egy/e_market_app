import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/premium_header_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../../data/models/subscription_model.dart';
import '../../../../features/localization/data/models/country_model.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class SubscriptionSelectionScreen extends StatefulWidget {
  const SubscriptionSelectionScreen({super.key});

  @override
  State<SubscriptionSelectionScreen> createState() =>
      _SubscriptionSelectionScreenState();
}

class _SubscriptionSelectionScreenState
    extends State<SubscriptionSelectionScreen> {
  SubscriptionModel? _selectedProduct;
  String? _selectedMarketType; // 'targetMarkets', 'otherMarkets', 'both', or 'importerMarkets'
  CountryModel? _selectedCountry;

  @override
  void initState() {
    super.initState();
    // Fetch active subscriptions
    di.sl<SubscriptionCubit>().getSubscriptions(activeOnly: true);
  }

  void _onSelectionChanged() {
    if (_selectedProduct != null && _selectedMarketType != null && _selectedCountry != null) {
      // Determine the actual market type to use
      String marketTypeToUse = _selectedMarketType!;
      if (_selectedMarketType == 'both') {
        // For "both", we need to check which market type the country belongs to
        final targetMarkets = _selectedProduct!.targetMarkets ?? [];
        final otherMarkets = _selectedProduct!.otherMarkets ?? [];
        
        if (targetMarkets.any((c) => c.id == _selectedCountry!.id)) {
          marketTypeToUse = AppConstants.marketTypeTarget;
        } else if (otherMarkets.any((c) => c.id == _selectedCountry!.id)) {
          marketTypeToUse = AppConstants.marketTypeOther;
        } else {
          // Country not found in either, use target as default
          marketTypeToUse = AppConstants.marketTypeTarget;
        }
      }
      
      // Trigger exploreMarket API call when all selections are made
      di.sl<SubscriptionCubit>().exploreMarket(
        productId: _selectedProduct!.productId,
        marketType: marketTypeToUse,
        countryId: _selectedCountry!.id,
      );
    }
  }

  List<CountryModel> _getAvailableCountries() {
    if (_selectedProduct == null || _selectedMarketType == null) {
      return [];
    }

    if (_selectedMarketType == 'both') {
      // Combine target and other markets
      final target = _selectedProduct!.targetMarkets ?? [];
      final other = _selectedProduct!.otherMarkets ?? [];
      final combined = [...target, ...other];
      // Remove duplicates
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
      return true; // Default to exporter
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
      // For exporters: show target, other, and both if both exist
      if (hasTarget) {
        types.add(AppConstants.marketTypeTarget);
      }
      if (hasOther) {
        types.add(AppConstants.marketTypeOther);
      }
      if (hasTarget && hasOther) {
        types.add('both');
      }
    } else {
      // Importer - only show importer markets
      if (hasImporter) {
        types.add(AppConstants.marketTypeImporter);
      }
    }

    return types;
  }

  String _getMarketTypeLabel(String marketType) {
    switch (marketType) {
      case AppConstants.marketTypeTarget:
        return 'Target Market';
      case AppConstants.marketTypeOther:
        return 'Other Market';
      case AppConstants.marketTypeImporter:
        return 'Importer Market';
      case 'both':
        return 'Both';
      default:
        return marketType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Premium Header Bar
          const PremiumHeaderBar(
            showBackButton: true,
          ),
          // Main Content
          Expanded(
            child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
              bloc: di.sl<SubscriptionCubit>(),
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

                if (state.subscriptions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No active subscriptions found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please subscribe to products to browse markets',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Dropdown Filters
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Product Dropdown
                          _buildProductDropdown(state.subscriptions),
                          const SizedBox(height: 16),
                          // Market Type Dropdown
                          if (_selectedProduct != null)
                            _buildMarketTypeDropdown(context),
                          const SizedBox(height: 16),
                          // Country Dropdown
                          if (_selectedProduct != null && _selectedMarketType != null)
                            _buildCountryDropdown(),
                        ],
                      ),
                    ),
                    // Action Buttons at the bottom when all selections are made
                    if (_selectedProduct != null &&
                        _selectedCountry != null &&
                        _selectedMarketType != null)
                      _buildActionButtons(
                        productId: _selectedProduct!.productId,
                        countryId: _selectedCountry!.id,
                        marketType: _selectedMarketType!,
                        state: state,
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

  Widget _buildProductDropdown(List<SubscriptionModel> subscriptions) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SubscriptionModel>(
          isExpanded: true,
          value: _selectedProduct,
          hint: const Text('Select Product'),
          items: subscriptions.map((subscription) {
            // Build display text with target market info
            final targetMarkets = subscription.targetMarkets ?? [];
            final targetMarketsText = targetMarkets.isNotEmpty
                ? ' (${targetMarkets.length} Target Markets)'
                : '';
            
            return DropdownMenuItem<SubscriptionModel>(
              value: subscription,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subscription.productName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (targetMarketsText.isNotEmpty)
                    Text(
                      targetMarketsText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: (SubscriptionModel? value) {
            setState(() {
              _selectedProduct = value;
              _selectedMarketType = null; // Reset market type
              _selectedCountry = null; // Reset country
            });
            _onSelectionChanged();
          },
        ),
      ),
    );
  }

  Widget _buildMarketTypeDropdown(BuildContext context) {
    final availableTypes = _getAvailableMarketTypes(context);
    
    if (availableTypes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          'No market types available for this product',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedMarketType,
          hint: const Text('Select Market Type'),
          items: availableTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(_getMarketTypeLabel(type)),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedMarketType = value;
              _selectedCountry = null; // Reset country when market type changes
            });
            _onSelectionChanged();
          },
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    final availableCountries = _getAvailableCountries();
    
    if (availableCountries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          'No countries available for this selection',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CountryModel>(
          isExpanded: true,
          value: _selectedCountry,
          hint: const Text('Select Country'),
          items: availableCountries.map((country) {
            return DropdownMenuItem<CountryModel>(
              value: country,
              child: Row(
                children: [
                  if (country.flagEmoji != null)
                    Text(
                      country.flagEmoji!,
                      style: const TextStyle(fontSize: 20),
                    )
                  else
                    const Icon(Icons.flag, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(country.name),
                        Text(
                          'Code: ${country.code}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (CountryModel? value) {
            setState(() {
              _selectedCountry = value;
            });
            _onSelectionChanged();
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons({
    required String productId,
    required int countryId,
    required String marketType,
    required SubscriptionState state,
  }) {
    // Show loading while fetching market data
    if (state.isLoading && state.marketExploration == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: LoadingIndicator(message: 'Loading market data...'),
      );
    }

    // Show error if there's an error and no data
    if (state.error != null && state.marketExploration == null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Error loading market data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                di.sl<SubscriptionCubit>().exploreMarket(
                  productId: productId,
                  marketType: marketType,
                  countryId: countryId,
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Get user type from auth
    final isExporter = _isExporter(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isExporter && marketType == AppConstants.marketTypeTarget) ...[
            AppButton(
              text: 'Importer List',
              onPressed: () {
                context.push(
                  '${RouteNames.profileList}?productId=$productId&countryId=$countryId&marketType=$marketType',
                );
              },
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Analysis',
              onPressed: () {
                context.push(
                  '${RouteNames.analysis}?productId=$productId&countryId=$countryId',
                );
              },
            ),
          ] else if (isExporter && marketType == AppConstants.marketTypeOther) ...[
            AppButton(
              text: 'Importer List',
              onPressed: () {
                context.push(
                  '${RouteNames.profileList}?productId=$productId&countryId=$countryId&marketType=$marketType',
                );
              },
            ),
          ] else ...[
            // Importer
            AppButton(
              text: 'Exporter List',
              onPressed: () {
                context.push(
                  '${RouteNames.profileList}?productId=$productId&countryId=$countryId&marketType=$marketType',
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../../../subscription/presentation/cubit/subscription_state.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class MarketSelectionScreen extends StatefulWidget {
  final String productId;
  final int countryId;
  final String marketType;

  const MarketSelectionScreen({super.key, required this.productId, required this.countryId, required this.marketType});

  @override
  State<MarketSelectionScreen> createState() => _MarketSelectionScreenState();
}

class _MarketSelectionScreenState extends State<MarketSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger exploreMarket API call when market is selected
    // This ensures analysis data is loaded before navigating to Analysis or ProfileList screens
    di.sl<SubscriptionCubit>().exploreMarket(productId: widget.productId, marketType: widget.marketType, countryId: widget.countryId);
  }

  bool _isExporter(BuildContext context) {
    try {
      final userTypeId = context.read<AuthCubit>().state.user?.userTypeId;
      return userTypeId == AppConstants.userTypeExporter;
    } catch (e) {
      return true; // Default to exporter if error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('market_selection'.tr())),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        bloc: di.sl<SubscriptionCubit>(),
        builder: (context, state) {
          // Show loading indicator while fetching market data
          if (state.isLoading && state.marketExploration == null) {
            return const LoadingIndicator(message: 'Loading market data...');
          }

          // Show error if there's an error and no data
          if (state.error != null && state.marketExploration == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('error_loading_market_data'.tr(), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(state.error!, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      di.sl<SubscriptionCubit>().exploreMarket(productId: widget.productId, marketType: widget.marketType, countryId: widget.countryId);
                    },
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          final isExporter = _isExporter(context);
          final isTargetMarket = widget.marketType == AppConstants.marketTypeTarget;
          final isOtherMarket = widget.marketType == AppConstants.marketTypeOther;
          final isImporterMarket = widget.marketType == AppConstants.marketTypeImporter;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${'product_id'.tr()}: ${widget.productId}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('${'country_id'.tr()}: ${widget.countryId}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 32),
                // Show profile list button based on user type and market type
                if (isExporter && (isTargetMarket || isOtherMarket)) ...[
                  AppButton(
                    text: '${'importer'.tr()} List',
                    onPressed: () {
                      context.push('${RouteNames.profileList}?productId=${widget.productId}&countryId=${widget.countryId}&marketType=${widget.marketType}');
                    },
                  ),
                  const SizedBox(height: 16),
                ] else if (!isExporter && isImporterMarket) ...[
                  AppButton(
                    text: '${'exporter'.tr()} List',
                    onPressed: () {
                      context.push('${RouteNames.profileList}?productId=${widget.productId}&countryId=${widget.countryId}&marketType=${widget.marketType}');
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                // Always show analysis button regardless of user type or market type
                AppButton(
                  text: 'analysis'.tr(),
                  onPressed: () {
                    context.push('${RouteNames.analysis}?productId=${widget.productId}&countryId=${widget.countryId}');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../../../subscription/presentation/cubit/subscription_state.dart';

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

  @override
  Widget build(BuildContext context) {
    // Get user type from auth (simplified - should come from auth state)
    // For now, show both options
    final isExporter = true; // TODO: Get from auth state

    return Scaffold(
      appBar: AppBar(title: const Text('Market Selection')),
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
                  Text('Error loading market data', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(state.error!, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      di.sl<SubscriptionCubit>().exploreMarket(productId: widget.productId, marketType: widget.marketType, countryId: widget.countryId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Product ID: ${widget.productId}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Country ID: ${widget.countryId}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 32),
                if (isExporter && widget.marketType == AppConstants.marketTypeTarget) ...[
                  AppButton(
                    text: 'Importer List',
                    onPressed: () {
                      context.push('${RouteNames.profileList}?productId=${widget.productId}&countryId=${widget.countryId}&marketType=${widget.marketType}');
                    },
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Analysis',
                    onPressed: () {
                      context.push('${RouteNames.analysis}?productId=${widget.productId}&countryId=${widget.countryId}');
                    },
                  ),
                ] else if (isExporter && widget.marketType == AppConstants.marketTypeOther) ...[
                  AppButton(
                    text: 'Importer List',
                    onPressed: () {
                      context.push('${RouteNames.profileList}?productId=${widget.productId}&countryId=${widget.countryId}&marketType=${widget.marketType}');
                    },
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Analysis',
                    onPressed: () {
                      context.push('${RouteNames.analysis}?productId=${widget.productId}&countryId=${widget.countryId}');
                    },
                  ),
                ] else ...[
                  // Importer
                  AppButton(
                    text: 'Exporter List',
                    onPressed: () {
                      context.push('${RouteNames.profileList}?productId=${widget.productId}&countryId=${widget.countryId}&marketType=${widget.marketType}');
                    },
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Analysis',
                    onPressed: () {
                      context.push('${RouteNames.analysis}?productId=${widget.productId}&countryId=${widget.countryId}');
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

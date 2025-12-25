import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../../data/models/subscription_model.dart';
import '../../../../features/localization/data/models/country_model.dart';

class SubscriptionSelectionScreen extends StatefulWidget {
  const SubscriptionSelectionScreen({super.key});

  @override
  State<SubscriptionSelectionScreen> createState() =>
      _SubscriptionSelectionScreenState();
}

class _SubscriptionSelectionScreenState
    extends State<SubscriptionSelectionScreen> {
  String? _expandedSubscriptionId;

  @override
  void initState() {
    super.initState();
    // Fetch active subscriptions
    di.sl<SubscriptionCubit>().getSubscriptions(activeOnly: true);
  }

  void _onMarketSelected({
    required String productId,
    required int countryId,
    required String marketType,
  }) {
    context.push(
      '${RouteNames.marketSelection}?productId=$productId&countryId=$countryId&marketType=$marketType',
    );
  }

  Widget _buildMarketList({
    required List<CountryModel> markets,
    required String marketType,
    required String marketLabel,
    required String productId,
  }) {
    if (markets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            marketLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...markets.map((country) {
          return ListTile(
            leading: country.flagEmoji != null
                ? Text(
                    country.flagEmoji!,
                    style: const TextStyle(fontSize: 24),
                  )
                : const Icon(Icons.flag),
            title: Text(country.name),
            subtitle: Text('Code: ${country.code}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _onMarketSelected(
              productId: productId,
              countryId: country.id,
              marketType: marketType,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubscriptionCard(SubscriptionModel subscription) {
    final isExpanded = _expandedSubscriptionId == subscription.id;
    final hasMarkets = (subscription.targetMarkets?.isNotEmpty ?? false) ||
        (subscription.otherMarkets?.isNotEmpty ?? false) ||
        (subscription.importerMarkets?.isNotEmpty ?? false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              subscription.productName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Product ID: ${subscription.productId}'),
            trailing: hasMarkets
                ? Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                  )
                : null,
            onTap: hasMarkets
                ? () {
                    setState(() {
                      _expandedSubscriptionId =
                          isExpanded ? null : subscription.id;
                    });
                  }
                : null,
          ),
          if (isExpanded && hasMarkets) ...[
            const Divider(height: 1),
            _buildMarketList(
              markets: subscription.targetMarkets ?? [],
              marketType: AppConstants.marketTypeTarget,
              marketLabel: 'Target Markets',
              productId: subscription.productId,
            ),
            _buildMarketList(
              markets: subscription.otherMarkets ?? [],
              marketType: AppConstants.marketTypeOther,
              marketLabel: 'Other Markets',
              productId: subscription.productId,
            ),
            _buildMarketList(
              markets: subscription.importerMarkets ?? [],
              marketType: AppConstants.marketTypeImporter,
              marketLabel: 'Importer Markets',
              productId: subscription.productId,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Product & Market'),
      ),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
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

          return ListView.builder(
            itemCount: state.subscriptions.length,
            itemBuilder: (context, index) {
              return _buildSubscriptionCard(state.subscriptions[index]);
            },
          );
        },
      ),
    );
  }
}


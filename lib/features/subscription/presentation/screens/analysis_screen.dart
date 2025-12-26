import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';

class AnalysisScreen extends StatefulWidget {
  final String productId;
  final int countryId;

  const AnalysisScreen({
    super.key,
    required this.productId,
    required this.countryId,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  @override
  void initState() {
    super.initState();
    // If data is not loaded, try to load it (handles direct navigation)
    final currentState = di.sl<SubscriptionCubit>().state;
    if (currentState.marketExploration == null && !currentState.isLoading) {
      // Note: We need marketType, but it's not passed to AnalysisScreen
      // For now, try with targetMarkets as default (this is a fallback)
      // Ideally, marketType should be passed as a parameter
      di.sl<SubscriptionCubit>().exploreMarket(
        productId: widget.productId,
        marketType: 'targetMarkets', // Default fallback
        countryId: widget.countryId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis')),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        bloc: di.sl<SubscriptionCubit>(),
        builder: (context, state) {
          // Show loading indicator while fetching
          if (state.isLoading && state.marketExploration == null) {
            return const LoadingIndicator(
              message: 'Loading analysis data...',
            );
          }

          // Show error if there's an error and no data
          if (state.error != null && state.marketExploration == null) {
            return AppErrorWidget(
              message: state.error!,
              onRetry: () {
                di.sl<SubscriptionCubit>().exploreMarket(
                  productId: widget.productId,
                  marketType: 'targetMarkets', // Default fallback
                  countryId: widget.countryId,
                );
              },
            );
          }

          final exploration = state.marketExploration;
          if (exploration == null) {
            return const Center(child: Text('No analysis data available'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (exploration.competitiveAnalysis != null)
                _buildAnalysisCard(
                  context,
                  'Competitive Analysis',
                  exploration.competitiveAnalysis!.isSeen,
                  () => context.push(
                    '${RouteNames.competitiveAnalysis}?productId=${widget.productId}&countryId=${widget.countryId}',
                  ),
                ),
              if (exploration.pestleAnalysis != null)
                _buildAnalysisCard(
                  context,
                  'PESTLE Analysis',
                  exploration.pestleAnalysis!.isSeen,
                  () => context.push(
                    '${RouteNames.pestleAnalysis}?productId=${widget.productId}&countryId=${widget.countryId}',
                  ),
                ),
              if (exploration.swotAnalysis != null)
                _buildAnalysisCard(
                  context,
                  'SWOT Analysis',
                  exploration.swotAnalysis!.isSeen,
                  () => context.push(
                    '${RouteNames.swotAnalysis}?productId=${widget.productId}&countryId=${widget.countryId}',
                  ),
                ),
              if (exploration.marketPlan != null)
                _buildAnalysisCard(
                  context,
                  'Market Plan',
                  exploration.marketPlan!.isSeen,
                  () => context.push(
                    '${RouteNames.marketPlan}?productId=${widget.productId}&countryId=${widget.countryId}',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnalysisCard(
    BuildContext context,
    String title,
    bool isUnlocked,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title),
        trailing: Icon(isUnlocked ? Icons.lock_open : Icons.lock),
        onTap: onTap,
      ),
    );
  }
}

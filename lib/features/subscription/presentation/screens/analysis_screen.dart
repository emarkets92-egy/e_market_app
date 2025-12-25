import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';

class AnalysisScreen extends StatelessWidget {
  final String productId;
  final int countryId;

  const AnalysisScreen({
    super.key,
    required this.productId,
    required this.countryId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis')),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        bloc: di.sl<SubscriptionCubit>(),
        builder: (context, state) {
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
                  exploration.competitiveAnalysis!.isNotEmpty,
                  () => context.push(
                    '${RouteNames.competitiveAnalysis}?productId=$productId&countryId=$countryId',
                  ),
                ),
              if (exploration.pestleAnalysis != null)
                _buildAnalysisCard(
                  context,
                  'PESTLE Analysis',
                  exploration.pestleAnalysis!.isSeen,
                  () => context.push(
                    '${RouteNames.pestleAnalysis}?productId=$productId&countryId=$countryId',
                  ),
                ),
              if (exploration.swotAnalysis != null)
                _buildAnalysisCard(
                  context,
                  'SWOT Analysis',
                  exploration.swotAnalysis!.isSeen,
                  () => context.push(
                    '${RouteNames.swotAnalysis}?productId=$productId&countryId=$countryId',
                  ),
                ),
              if (exploration.marketPlan != null)
                _buildAnalysisCard(
                  context,
                  'Market Plan',
                  exploration.marketPlan!.isSeen,
                  () => context.push(
                    '${RouteNames.marketPlan}?productId=$productId&countryId=$countryId',
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

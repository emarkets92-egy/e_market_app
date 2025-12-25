import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/constants/app_constants.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../widgets/blurred_content_widget.dart';
import '../widgets/unlock_button.dart';
import '../../../points/presentation/cubit/points_cubit.dart';

class CompetitiveAnalysisScreen extends StatelessWidget {
  final String productId;
  final int countryId;

  const CompetitiveAnalysisScreen({
    super.key,
    required this.productId,
    required this.countryId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Competitive Analysis')),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        bloc: di.sl<SubscriptionCubit>(),
        builder: (context, state) {
          final exploration = state.marketExploration;
          if (exploration == null || exploration.competitiveAnalysis == null) {
            return const Center(
              child: Text('No competitive analysis available'),
            );
          }

          final analysis = exploration.competitiveAnalysis!;
          if (analysis.isEmpty) {
            return const Center(child: Text('No competitive analysis data'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: analysis.length,
            itemBuilder: (context, index) {
              final item = analysis[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.marketName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      BlurredContentWidget(
                        isUnlocked: item.isSeen,
                        unlockCost: item.unlockCost,
                        currentBalance: _getBalance(context),
                        onUnlock: item.isSeen
                            ? null
                            : () {
                                di.sl<SubscriptionCubit>().unlockAnalysis(
                                  productId: productId,
                                  countryId: countryId,
                                  analysisType:
                                      AppConstants.analysisTypeCompetitive,
                                );
                              },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Imports: ${item.totalImports}'),
                            Text(
                              'Total Exports: ${item.totalExportsFromSelectedCountry}',
                            ),
                            Text('Rank: ${item.rank}'),
                          ],
                        ),
                      ),
                      if (!item.isSeen)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: UnlockButton(
                            cost: item.unlockCost,
                            currentBalance: _getBalance(context),
                            onUnlock: () {
                              di.sl<SubscriptionCubit>().unlockAnalysis(
                                productId: productId,
                                countryId: countryId,
                                analysisType:
                                    AppConstants.analysisTypeCompetitive,
                              );
                            },
                            isLoading: state.isUnlocking,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  int _getBalance(BuildContext context) {
    return di.sl<PointsCubit>().state.balance;
  }
}

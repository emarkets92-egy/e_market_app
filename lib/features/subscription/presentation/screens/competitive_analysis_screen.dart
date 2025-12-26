import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../widgets/blurred_content_widget.dart';
import '../widgets/unlock_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/unlock_item_model.dart';

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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.marketName ?? 'Competitive Analysis',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    BlurredContentWidget(
                      isUnlocked: analysis.isSeen,
                      unlockCost: analysis.unlockCost,
                      currentBalance: _getBalance(context),
                        onUnlock: analysis.isSeen
                            ? null
                            : () {
                                di.sl<SubscriptionCubit>().unlock(
                                  contentType: ContentType.competitiveAnalysis,
                                  targetId: analysis.id,
                                );
                              },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (analysis.totalImports != null)
                            Text('Total Imports: ${analysis.totalImports}'),
                          if (analysis.totalExportsFromSelectedCountry != null)
                            Text(
                              'Total Exports: ${analysis.totalExportsFromSelectedCountry}',
                            ),
                          if (analysis.rank != null)
                            Text('Rank: ${analysis.rank}'),
                          if (analysis.totalImports == null &&
                              analysis.totalExportsFromSelectedCountry ==
                                  null &&
                              analysis.rank == null)
                            const Text(
                              'Analysis data will be available after unlocking',
                            ),
                        ],
                      ),
                    ),
                    if (!analysis.isSeen)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: UnlockButton(
                          cost: analysis.unlockCost,
                          currentBalance: _getBalance(context),
                          onUnlock: () {
                            di.sl<SubscriptionCubit>().unlock(
                              contentType: ContentType.competitiveAnalysis,
                              targetId: analysis.id,
                            );
                          },
                          isLoading: state.isUnlocking,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  int _getBalance(BuildContext context) {
    return di.sl<AuthCubit>().state.user?.points ?? 0;
  }
}

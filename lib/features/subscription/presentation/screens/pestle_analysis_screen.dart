import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/constants/app_constants.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../widgets/blurred_content_widget.dart';
import '../widgets/unlock_button.dart';
import '../../../points/presentation/cubit/points_cubit.dart';

class PESTLEAnalysisScreen extends StatelessWidget {
  final String productId;
  final int countryId;

  const PESTLEAnalysisScreen({
    super.key,
    required this.productId,
    required this.countryId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PESTLE Analysis')),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        bloc: di.sl<SubscriptionCubit>(),
        builder: (context, state) {
          final exploration = state.marketExploration;
          if (exploration == null || exploration.pestleAnalysis == null) {
            return const Center(child: Text('No PESTLE analysis available'));
          }

          final analysis = exploration.pestleAnalysis!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlurredContentWidget(
                      isUnlocked: analysis.isSeen,
                      unlockCost: analysis.unlockCost,
                      currentBalance: _getBalance(context),
                      onUnlock: analysis.isSeen
                          ? null
                          : () {
                              di.sl<SubscriptionCubit>().unlockAnalysis(
                                productId: productId,
                                countryId: countryId,
                                analysisType: AppConstants.analysisTypePestle,
                              );
                            },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (analysis.political != null)
                            _buildSection('Political', analysis.political!),
                          if (analysis.economic != null)
                            _buildSection('Economic', analysis.economic!),
                          if (analysis.social != null)
                            _buildSection('Social', analysis.social!),
                          if (analysis.technological != null)
                            _buildSection(
                              'Technological',
                              analysis.technological!,
                            ),
                          if (analysis.legal != null)
                            _buildSection('Legal', analysis.legal!),
                          if (analysis.environmental != null)
                            _buildSection(
                              'Environmental',
                              analysis.environmental!,
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
                            di.sl<SubscriptionCubit>().unlockAnalysis(
                              productId: productId,
                              countryId: countryId,
                              analysisType: AppConstants.analysisTypePestle,
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

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }

  int _getBalance(BuildContext context) {
    return di.sl<PointsCubit>().state.balance;
  }
}

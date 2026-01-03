import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../widgets/blurred_content_widget.dart';
import '../widgets/unlock_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/unlock_item_model.dart';

class SWOTAnalysisScreen extends StatelessWidget {
  final String productId;
  final int countryId;

  const SWOTAnalysisScreen({super.key, required this.productId, required this.countryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SWOT Analysis')),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        bloc: di.sl<SubscriptionCubit>(),
        builder: (context, state) {
          final exploration = state.marketExploration;
          if (exploration == null || exploration.swotAnalysis == null) {
            return const Center(child: Text('No SWOT analysis available'));
          }

          final analysis = exploration.swotAnalysis!;

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
                              if (analysis.id != null) {
                                di.sl<SubscriptionCubit>().unlock(contentType: ContentType.swotAnalysis, targetId: analysis.id!);
                              }
                            },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (analysis.strengths != null) _buildSection('Strengths', analysis.strengths!),
                          if (analysis.weaknesses != null) _buildSection('Weaknesses', analysis.weaknesses!),
                          if (analysis.opportunities != null) _buildSection('Opportunities', analysis.opportunities!),
                          if (analysis.threats != null) _buildSection('Threats', analysis.threats!),
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
                            if (analysis.id != null) {
                              di.sl<SubscriptionCubit>().unlock(contentType: ContentType.swotAnalysis, targetId: analysis.id!);
                            }
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
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }

  int _getBalance(BuildContext context) {
    return di.sl<AuthCubit>().state.user?.points ?? 0;
  }
}

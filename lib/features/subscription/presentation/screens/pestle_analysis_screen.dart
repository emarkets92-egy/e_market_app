import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../widgets/blurred_content_widget.dart';
import '../widgets/unlock_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/unlock_item_model.dart';

class PESTLEAnalysisScreen extends StatelessWidget {
  final String productId;
  final int countryId;

  const PESTLEAnalysisScreen({super.key, required this.productId, required this.countryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('pestle_analysis'.tr())),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        bloc: di.sl<SubscriptionCubit>(),
        builder: (context, state) {
          final exploration = state.marketExploration;
          if (exploration == null || exploration.pestleAnalysis == null) {
            return Center(child: Text('no_pestle_analysis'.tr()));
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
                              if (analysis.id != null) {
                                di.sl<SubscriptionCubit>().unlock(contentType: ContentType.pestleAnalysis, targetId: analysis.id!);
                              }
                            },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (analysis.political != null) _buildSection('political'.tr(), analysis.political!),
                          if (analysis.economic != null) _buildSection('economic'.tr(), analysis.economic!),
                          if (analysis.social != null) _buildSection('social'.tr(), analysis.social!),
                          if (analysis.technological != null) _buildSection('technological'.tr(), analysis.technological!),
                          if (analysis.legal != null) _buildSection('legal'.tr(), analysis.legal!),
                          if (analysis.environmental != null) _buildSection('environmental'.tr(), analysis.environmental!),
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
                              di.sl<SubscriptionCubit>().unlock(contentType: ContentType.pestleAnalysis, targetId: analysis.id!);
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

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

class MarketPlanScreen extends StatelessWidget {
  final String productId;
  final int countryId;

  const MarketPlanScreen({super.key, required this.productId, required this.countryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('market_plan'.tr())),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        bloc: di.sl<SubscriptionCubit>(),
        builder: (context, state) {
          final exploration = state.marketExploration;
          if (exploration == null || exploration.marketPlan == null) {
            return Center(child: Text('no_market_plan'.tr()));
          }

          final plan = exploration.marketPlan!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlurredContentWidget(
                      isUnlocked: plan.isSeen,
                      unlockCost: plan.unlockCost,
                      currentBalance: _getBalance(context),
                      onUnlock: plan.isSeen
                          ? null
                          : () {
                              if (plan.id != null) {
                                di.sl<SubscriptionCubit>().unlock(contentType: ContentType.marketPlan, targetId: plan.id!);
                              }
                            },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (plan.productText != null) _buildSection('product_label'.tr(), plan.productText!),
                          if (plan.priceText != null) _buildSection('price'.tr(), plan.priceText!),
                          if (plan.placeText != null) _buildSection('place'.tr(), plan.placeText!),
                          if (plan.promotionText != null) _buildSection('promotion'.tr(), plan.promotionText!),
                        ],
                      ),
                    ),
                    if (!plan.isSeen)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: UnlockButton(
                          cost: plan.unlockCost,
                          currentBalance: _getBalance(context),
                          onUnlock: () {
                            if (plan.id != null) {
                              di.sl<SubscriptionCubit>().unlock(contentType: ContentType.marketPlan, targetId: plan.id!);
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

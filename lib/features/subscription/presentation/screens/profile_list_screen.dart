import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../widgets/profile_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';

class ProfileListScreen extends StatefulWidget {
  final String productId;
  final int countryId;
  final String marketType;

  const ProfileListScreen({
    super.key,
    required this.productId,
    required this.countryId,
    required this.marketType,
  });

  @override
  State<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  @override
  void initState() {
    super.initState();
    di.sl<SubscriptionCubit>().exploreMarket(
      productId: widget.productId,
      marketType: widget.marketType,
      countryId: widget.countryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profiles')),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        bloc: di.sl<SubscriptionCubit>(),
        builder: (context, state) {
          if (state.isLoading && state.profiles.isEmpty) {
            return const LoadingIndicator();
          }

          if (state.error != null && state.profiles.isEmpty) {
            return AppErrorWidget(
              message: state.error!,
              onRetry: () {
                di.sl<SubscriptionCubit>().exploreMarket(
                  productId: widget.productId,
                  marketType: widget.marketType,
                  countryId: widget.countryId,
                );
              },
            );
          }

          if (state.profiles.isEmpty) {
            return const Center(child: Text('No profiles found'));
          }

          return ListView.builder(
            itemCount: state.profiles.length,
            itemBuilder: (context, index) {
              final profile = state.profiles[index];
              return ProfileCard(
                profile: profile,
                isUnlocking: state.isUnlocking,
                onUnlock: () {
                  di.sl<SubscriptionCubit>().unlockProfile(
                    productId: widget.productId,
                    targetProfileId: profile.id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

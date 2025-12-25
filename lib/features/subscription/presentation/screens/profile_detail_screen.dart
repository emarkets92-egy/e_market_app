import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';

class ProfileDetailScreen extends StatelessWidget {
  final String profileId;

  const ProfileDetailScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Details')),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        bloc: di.sl<SubscriptionCubit>(),
        builder: (context, state) {
          if (state.profiles.isEmpty) {
            return const Center(child: Text('Profile not found'));
          }

          final profile = state.profiles.firstWhere(
            (p) => p.id == profileId,
            orElse: () => state.profiles.first, // Fallback to first profile
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  profile.companyName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (profile.email != null) Text('Email: ${profile.email}'),
                if (profile.phone != null) Text('Phone: ${profile.phone}'),
                if (profile.whatsapp != null)
                  Text('WhatsApp: ${profile.whatsapp}'),
                if (profile.website != null)
                  Text('Website: ${profile.website}'),
                if (profile.address != null)
                  Text('Address: ${profile.address}'),
                const SizedBox(height: 8),
                Text('Country: ${profile.country.name}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
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
          // Search in both unseen and seen profiles
          final allProfiles = [
            ...state.unseenProfiles,
            ...state.seenProfiles,
          ];

          if (allProfiles.isEmpty) {
            return const Center(child: Text('Profile not found'));
          }

          final profile = allProfiles.firstWhere(
            (p) => p.id == profileId,
            orElse: () => allProfiles.first, // Fallback to first profile
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile ${profile.id.substring(0, 8)}...',
                  style: Theme.of(context).textTheme.headlineMedium,
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
                if (profile.shipmentRecords != null)
                  Text('Shipment Records: ${profile.shipmentRecords}'),
                if (profile.isSeen) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push(
                        '${RouteNames.shipmentRecordsList.replaceAll(':profileId', profile.id)}',
                      );
                    },
                    icon: const Icon(Icons.local_shipping),
                    label: const Text('View Shipment Records'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../data/models/profile_model.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/presentation/cubit/auth_cubit.dart';
import 'blurred_content_widget.dart';
import 'unlock_button.dart';

class ProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onUnlock;
  final bool isUnlocking;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.onUnlock,
    this.isUnlocking = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          context.push(
            '${RouteNames.profileDetail.replaceAll(':id', profile.id)}',
          );
        },
          child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile ${profile.id.substring(0, 8)}...',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              if (profile.shipmentRecords != null)
                Text('Shipment Records: ${profile.shipmentRecords}'),
              const SizedBox(height: 16),
              BlurredContentWidget(
                isUnlocked: profile.isSeen,
                unlockCost: profile.unlockCost,
                currentBalance: _getCurrentBalance(context),
                onUnlock: profile.isSeen ? null : onUnlock,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (profile.email != null) Text('Email: ${profile.email}'),
                    if (profile.phone != null) Text('Phone: ${profile.phone}'),
                    if (profile.whatsapp != null)
                      Text('WhatsApp: ${profile.whatsapp}'),
                    if (profile.website != null)
                      Text('Website: ${profile.website}'),
                    if (profile.address != null)
                      Text('Address: ${profile.address}'),
                  ],
                ),
              ),
              if (!profile.isSeen)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: UnlockButton(
                    cost: profile.unlockCost,
                    currentBalance: _getCurrentBalance(context),
                    onUnlock: onUnlock,
                    isLoading: isUnlocking,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  int _getCurrentBalance(BuildContext context) {
    try {
      return context.read<AuthCubit>().state.user?.points ?? 0;
    } catch (e) {
      return di.sl<AuthCubit>().state.user?.points ?? 0;
    }
  }
}

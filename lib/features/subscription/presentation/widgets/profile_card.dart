import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
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

  const ProfileCard({super.key, required this.profile, required this.onUnlock, this.isUnlocking = false});

  @override
  Widget build(BuildContext context) {
    final balance = _getCurrentBalance(context);

    return Card(
      margin: EdgeInsets.zero, // Margin is handled by GridView spacing
      child: InkWell(
        onTap: () {
          context.push(RouteNames.profileDetail.replaceAll(':id', profile.id));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Title - always visible
              BlurredContentWidget(
                isUnlocked: profile.isSeen,
                unlockCost: profile.unlockCost,
                currentBalance: balance,
                onUnlock: profile.isSeen ? null : onUnlock,
                child: Text(
                  profile.companyName ?? 'Profile ${profile.id.substring(0, 8)}...',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 4),
              // Shipment Records - always visible
              if (profile.shipmentRecords != null)
                Text(
                  'shipment_records_count'.tr(namedArgs: {'count': profile.shipmentRecords.toString()}),
                  style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
                ),
              const SizedBox(height: 16),
              // All content wrapped in BlurredContentWidget
              // For unseen profiles, this will show blurred content
              // For seen profiles, this will show normal content
              BlurredContentWidget(
                isUnlocked: profile.isSeen,
                unlockCost: profile.unlockCost,
                currentBalance: balance,
                onUnlock: profile.isSeen ? null : onUnlock,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (profile.companyName != null && profile.isSeen) Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text('${'company_name'.tr()}: ${profile.companyName}')),
                    if (profile.email != null) Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text('${'email'.tr()}: ${profile.email}')),
                    if (profile.phone != null) Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text('${'phone'.tr()}: ${profile.phone}')),
                    if (profile.whatsapp != null) Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text('${'whatsapp'.tr()}: ${profile.whatsapp}')),
                    if (profile.website != null) Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text('${'website'.tr()}: ${profile.website}')),
                    if (profile.address != null) Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text('${'address'.tr()}: ${profile.address}')),
                  ],
                ),
              ),
              // Unlock button - always visible for unseen profiles (outside blurred widget)
              if (!profile.isSeen)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: UnlockButton(cost: profile.unlockCost, currentBalance: balance, onUnlock: onUnlock, isLoading: isUnlocking),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/profile_model.dart';
import 'blurred_content_widget.dart';

class SubscriptionProfileTableRow extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onUnlock;
  final bool isUnlocking;
  final bool disableUnlockButton;

  const SubscriptionProfileTableRow({super.key, required this.profile, required this.onUnlock, this.isUnlocking = false, this.disableUnlockButton = false});

  int _getCurrentBalance(BuildContext context) {
    try {
      return context.read<AuthCubit>().state.user?.points ?? 0;
    } catch (e) {
      return di.sl<AuthCubit>().state.user?.points ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = _getCurrentBalance(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          // IMPORTER NAME
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                  child: Icon(Icons.business, size: 16, color: Colors.grey[400]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BlurredContentWidget(
                    isUnlocked: profile.isSeen,
                    unlockCost: profile.unlockCost,
                    currentBalance: balance,
                    onUnlock: profile.isSeen ? null : onUnlock,
                    child: Text(
                      profile.companyName ?? profile.email?.split('@').first ?? 'Importer ${profile.id.substring(0, 8)}',
                      style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // EMAIL
          Expanded(
            flex: 2,
            child: BlurredContentWidget(
              isUnlocked: profile.isSeen,
              unlockCost: profile.unlockCost,
              currentBalance: balance,
              onUnlock: profile.isSeen ? null : onUnlock,
              child: profile.email != null
                  ? Row(
                      children: [
                        if (profile.isSeen) Icon(Icons.email_outlined, size: 16, color: Colors.grey[400]),
                        if (profile.isSeen) const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            profile.email!,
                            style: TextStyle(color: profile.isSeen ? Colors.black87 : Colors.grey[400]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : Text('-', style: TextStyle(color: Colors.grey[400])),
            ),
          ),
          const SizedBox(width: 16),
          // PHONE
          Expanded(
            flex: 2,
            child: BlurredContentWidget(
              isUnlocked: profile.isSeen,
              unlockCost: profile.unlockCost,
              currentBalance: balance,
              onUnlock: profile.isSeen ? null : onUnlock,
              child: profile.phone != null
                  ? Text(
                      profile.phone!,
                      style: TextStyle(color: profile.isSeen ? Colors.black87 : Colors.grey[400]),
                      overflow: TextOverflow.ellipsis,
                    )
                  : Container(width: 20, height: 20, color: Colors.grey[200]),
            ),
          ),
          const SizedBox(width: 16),
          // WEBSITE
          Expanded(
            flex: 2,
            child: BlurredContentWidget(
              isUnlocked: profile.isSeen,
              unlockCost: profile.unlockCost,
              currentBalance: balance,
              onUnlock: profile.isSeen ? null : onUnlock,
              child: profile.website != null
                  ? Text(
                      profile.website!,
                      style: TextStyle(color: profile.isSeen ? Colors.blue : Colors.grey[400]),
                      overflow: TextOverflow.ellipsis,
                    )
                  : Container(width: 20, height: 20, color: Colors.grey[200]),
            ),
          ),
          const SizedBox(width: 16),
          // ACTIONS
          SizedBox(
            width: 160,
            child: profile.isSeen
                ? OutlinedButton.icon(
                    onPressed: () {
                      context.push('/profiles/${profile.id}');
                    },
                    icon: const Icon(Icons.visibility, size: 16),
                    label: Text('view'.tr()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  )
                : SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: (isUnlocking || disableUnlockButton) ? null : onUnlock,
                      icon: isUnlocking
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.lock_open, size: 16, color: Colors.white),
                      label: Text('credit_to_unlock'.tr(namedArgs: {'cost': profile.unlockCost.toString()}), style: const TextStyle(fontSize: 12, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

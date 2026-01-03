import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/profile_model.dart';
import 'blurred_content_widget.dart';
import 'unlock_button.dart';

class ProfileTableRow extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onUnlock;
  final bool isUnlocking;

  const ProfileTableRow({super.key, required this.profile, required this.onUnlock, this.isUnlocking = false});

  int _getCurrentBalance(BuildContext context) {
    try {
      return context.read<AuthCubit>().state.user?.points ?? 0;
    } catch (e) {
      return di.sl<AuthCubit>().state.user?.points ?? 0;
    }
  }

  String _getInitials(String id) {
    if (id.length >= 2) {
      return id.substring(0, 2).toUpperCase();
    }
    return id.substring(0, 1).toUpperCase();
  }

  Color _getAvatarColor(String id) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.pink, Colors.red, Colors.lightBlue];
    final index = id.hashCode % colors.length;
    return colors[index.abs()];
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback: copy to clipboard or show error
      debugPrint('Could not launch email: $email');
    }
  }

  Future<void> _launchWhatsApp(String whatsapp) async {
    // Remove any non-digit characters except +
    final cleaned = whatsapp.replaceAll(RegExp(r'[^\d+]'), '');
    // Ensure it starts with country code (add + if not present and it's a long number)
    String phoneNumber = cleaned;
    if (!phoneNumber.startsWith('+')) {
      // If it's a long number without +, assume it needs country code
      // For now, just use as is - user can adjust
      phoneNumber = phoneNumber;
    }

    // Try WhatsApp URL scheme first
    final whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to tel: link
      final telUri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        debugPrint('Could not launch WhatsApp: $whatsapp');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = _getCurrentBalance(context);
    final initials = _getInitials(profile.id);
    final avatarColor = _getAvatarColor(profile.id);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // PROFILE (Avatar)
              SizedBox(
                width: 80,
                child: BlurredContentWidget(
                  isUnlocked: profile.isSeen,
                  unlockCost: profile.unlockCost,
                  currentBalance: balance,
                  onUnlock: profile.isSeen ? null : onUnlock,
                  child: CircleAvatar(
                    backgroundColor: avatarColor,
                    radius: 20,
                    child: Text(
                      initials,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // IMPORTER NAME
              Expanded(
                flex: 2,
                child: BlurredContentWidget(
                  isUnlocked: profile.isSeen,
                  unlockCost: profile.unlockCost,
                  currentBalance: balance,
                  onUnlock: profile.isSeen ? null : onUnlock,
                  child: Text(
                    profile.email
                            ?.split('@')
                            .first
                            .replaceAll('.', ' ')
                            .split(' ')
                            .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
                            .join(' ') ??
                        'Importer ${profile.id.substring(0, 8)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
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
                      ? profile.isSeen
                            ? InkWell(
                                onTap: () => _launchEmail(profile.email!),
                                child: Text(
                                  profile.email!,
                                  style: TextStyle(color: Colors.blue[700], decoration: TextDecoration.underline),
                                ),
                              )
                            : Text(profile.email!, style: TextStyle(color: Colors.grey[700]))
                      : Text('N/A', style: TextStyle(color: Colors.grey[400])),
                ),
              ),
              const SizedBox(width: 16),
              // WHATSAPP
              Expanded(
                flex: 1,
                child: BlurredContentWidget(
                  isUnlocked: profile.isSeen,
                  unlockCost: profile.unlockCost,
                  currentBalance: balance,
                  onUnlock: profile.isSeen ? null : onUnlock,
                  child: profile.whatsapp != null
                      ? profile.isSeen
                            ? InkWell(
                                onTap: () => _launchWhatsApp(profile.whatsapp!),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.chat, size: 16, color: Colors.green[700]),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        profile.whatsapp!,
                                        style: TextStyle(color: Colors.green[700], decoration: TextDecoration.underline),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Text(profile.whatsapp!, style: TextStyle(color: Colors.grey[700]))
                      : Text('N/A', style: TextStyle(color: Colors.grey[400])),
                ),
              ),
            ],
          ),
          // Shipment Records and Unlock Button (always visible for unseen)
          if (!profile.isSeen) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (profile.shipmentRecords != null)
                  Text(
                    'Shipment Records: ${profile.shipmentRecords}',
                    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
                  ),
                UnlockButton(cost: profile.unlockCost, currentBalance: balance, onUnlock: onUnlock, isLoading: isUnlocking),
              ],
            ),
          ] else if (profile.shipmentRecords != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Shipment Records: ${profile.shipmentRecords}',
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

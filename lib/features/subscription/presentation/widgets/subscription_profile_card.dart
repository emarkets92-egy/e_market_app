import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/profile_model.dart';
import 'blurred_content_widget.dart';

class SubscriptionProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onUnlock;
  final bool isUnlocking;
  final bool disableUnlockButton;

  const SubscriptionProfileCard({super.key, required this.profile, required this.onUnlock, this.isUnlocking = false, this.disableUnlockButton = false});

  int _getCurrentBalance(BuildContext context) {
    try {
      return context.read<AuthCubit>().state.user?.points ?? 0;
    } catch (e) {
      return di.sl<AuthCubit>().state.user?.points ?? 0;
    }
  }

  Future<void> _launchUrl(String? urlString, {String scheme = 'https'}) async {
    if (urlString == null || urlString.isEmpty) return;

    final Uri uri;
    if (scheme == 'mailto') {
      uri = Uri.parse('mailto:$urlString');
    } else if (scheme == 'tel') {
      uri = Uri.parse('tel:$urlString');
    } else {
      if (!urlString.startsWith('http')) {
        uri = Uri.parse('https://$urlString');
      } else {
        uri = Uri.parse(urlString);
      }
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch: $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = _getCurrentBalance(context);

    return Container(
      height: profile.isSeen ? 430 : 320, // Extra room for phone pill
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // More rounded
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
        // border: Border.all(color: Colors.grey[200]!), // Removed border to match clean look or keep subtle
      ),
      padding: EdgeInsets.all(profile.isSeen ? 20 : 20), // Reduced padding for locked card
      child: profile.isSeen ? _buildUnlockedCard(context, balance) : _buildLockedCard(context, balance),
    );
  }

  Widget _buildLockedCard(BuildContext context, int balance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Importer locked" text at the top
        const Text(
          'Importer locked',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 8),

        // Dashed border box with lock icon and unlock button
        _buildDashedBorderContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lock icon with "CONTACT INFO" text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 18, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'CONTACT INFO',
                      style: TextStyle(color: Color(0xFF555555), fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Large unlock button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: (isUnlocking || disableUnlockButton) ? null : onUnlock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isUnlocking
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(
                            '${profile.unlockCost} ${profile.unlockCost == 1 ? 'Credit' : 'Credits'} to Unlock',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Footer with action icons (person and chat)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildActionIconButton(
              icon: Icons.person,
              onTap: () {
                // Navigate to profile detail even if locked
                context.push('/profiles/${profile.id}');
              },
            ),
            const SizedBox(width: 8),
            _buildActionIconButton(
              icon: Icons.chat_bubble_outline,
              onTap: () {
                // Chat action
                context.push('/profiles/${profile.id}');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnlockedCard(BuildContext context, int balance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.companyName ??
                  (profile.email
                          ?.split('@')
                          .first
                          .replaceAll('.', ' ')
                          .split(' ')
                          .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
                          .join(' ') ??
                      'Importer ${profile.id.substring(0, 8)}'),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Color(0xFF1A1A1A)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            const Text(
              'Importer', // Placeholder as "Role" is not in model yet
              style: TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Contact Info Pills
        _buildContactPill(
          icon: Icons.email, // Using filled icon style
          value: profile.email,
          isSeen: profile.isSeen,
          balance: balance,
          onTap: () => _launchUrl(profile.email, scheme: 'mailto'),
          emptyPlaceholder: 'Soon',
        ),

        const SizedBox(height: 10),

        _buildTelContactPill(
          icon: Icons.phone,
          value: profile.phone,
          isSeen: profile.isSeen,
          balance: balance,
          onTap: () => _launchUrl(profile.phone, scheme: 'tel'),
          emptyPlaceholder: 'Soon',
        ),

        const Spacer(),
        const SizedBox(height: 8),

        // Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Website Link
            InkWell(
              onTap: (profile.website != null && profile.website!.isNotEmpty) ? () => _launchUrl(profile.website) : null,
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.link, size: 18, color: (profile.website != null && profile.website!.isNotEmpty) ? Colors.blue[600] : Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text(
                    (profile.website != null && profile.website!.isNotEmpty) ? 'Website' : 'Soon',
                    style: TextStyle(
                      color: (profile.website != null && profile.website!.isNotEmpty) ? Colors.blue[600] : Colors.grey[400],
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Row(
              children: [
                // View Profile
                _buildActionIconButton(
                  icon: Icons.person,
                  onTap: () {
                    context.push('/profiles/${profile.id}');
                  },
                ),
                const SizedBox(width: 8),
                // Shipment Records or other action
                _buildActionIconButton(
                  icon: Icons.description, // List/Document icon
                  onTap: () {
                    // Navigate to shipment records or details
                    context.push('/profiles/${profile.id}');
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactPill({required IconData icon, required String? value, required bool isSeen, required int balance, VoidCallback? onTap, String emptyPlaceholder = 'N/A'}) {
    final display = (value != null && value.isNotEmpty) ? value : emptyPlaceholder;
    return BlurredContentWidget(
      isUnlocked: isSeen,
      unlockCost: profile.unlockCost,
      currentBalance: balance,
      onUnlock: isSeen ? null : onUnlock,
      child: InkWell(
        onTap: (isSeen && value != null && value.isNotEmpty) ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB), // Light background for pill
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.blue[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  display,
                  style: TextStyle(color: (value != null && value.isNotEmpty) ? const Color(0xFF555555) : Colors.grey[400], fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelContactPill({
    required IconData icon,
    required String? value,
    required bool isSeen,
    required int balance,
    VoidCallback? onTap,
    String emptyPlaceholder = 'N/A',
  }) {
    final display = (value != null && value.isNotEmpty) ? value : emptyPlaceholder;

    return BlurredContentWidget(
      isUnlocked: isSeen,
      unlockCost: profile.unlockCost,
      currentBalance: balance,
      onUnlock: isSeen ? null : onUnlock,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.blue[600]),
            const SizedBox(width: 12),
            Expanded(
              child: (value != null && value.isNotEmpty)
                  ? SelectableText.rich(
                      TextSpan(
                        text: display,
                        style: const TextStyle(color: Color(0xFF555555), fontSize: 14, decoration: TextDecoration.underline),
                        recognizer: (TapGestureRecognizer()..onTap = () => onTap?.call()),
                      ),
                      maxLines: 1,
                    )
                  : Text(
                      display,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F5), // Light grey background
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF333333)),
      ),
    );
  }

  Widget _buildDashedBorderContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: CustomPaint(painter: DashedBorderPainter(), child: child),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(12)));

    // Create dashed effect
    final dashWidth = 5.0;
    final dashSpace = 3.0;
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      var distance = 0.0;
      while (distance < pathMetric.length) {
        final path = pathMetric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(path, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

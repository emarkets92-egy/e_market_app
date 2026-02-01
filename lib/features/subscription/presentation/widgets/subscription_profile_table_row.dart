import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/profile_model.dart';
import 'blurred_content_widget.dart';

class SubscriptionProfileTableRow extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onUnlock;
  final bool isUnlocking;
  final bool disableUnlockButton;
  final Map<String, int> columnFlex;

  static const List<String> _columns = ['name', 'email', 'phone', 'website', 'actions'];

  const SubscriptionProfileTableRow({
    super.key,
    required this.profile,
    required this.onUnlock,
    this.isUnlocking = false,
    this.disableUnlockButton = false,
    required this.columnFlex,
  });

  int _getCurrentBalance(BuildContext context) {
    try {
      return context.read<AuthCubit>().state.user?.points ?? 0;
    } catch (e) {
      return di.sl<AuthCubit>().state.user?.points ?? 0;
    }
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final uri = urlString.startsWith('http') ? Uri.parse(urlString) : Uri.parse('https://$urlString');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchTel(String? phone) async {
    if (phone == null || phone.trim().isEmpty) return;
    final uri = Uri.parse('tel:${phone.trim()}');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  Widget _buildSelectableTelText(String phone, {required bool isEnabled}) {
    final textStyle = TextStyle(
      color: isEnabled ? Colors.blue : Colors.grey[400],
      decoration: isEnabled ? TextDecoration.underline : null,
    );

    return SelectableText.rich(
      TextSpan(
        text: phone,
        style: textStyle,
        recognizer: isEnabled ? (TapGestureRecognizer()..onTap = () => _launchTel(phone)) : null,
      ),
      maxLines: 1,
    );
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
        children: _columns.map((column) {
          final flex = columnFlex[column] ?? 1;
          Widget child;
          switch (column) {
            case 'name':
              child = Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                    child: Icon(Icons.business, size: 16, color: Colors.grey[400]),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
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
              );
              break;
            case 'email':
              child = BlurredContentWidget(
                isUnlocked: profile.isSeen,
                unlockCost: profile.unlockCost,
                currentBalance: balance,
                onUnlock: profile.isSeen ? null : onUnlock,
                child: profile.email != null && profile.email!.isNotEmpty
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
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
                    : Text('Soon', style: TextStyle(color: Colors.grey[400])),
              );
              break;
            case 'phone':
              child = BlurredContentWidget(
                isUnlocked: profile.isSeen,
                unlockCost: profile.unlockCost,
                currentBalance: balance,
                onUnlock: profile.isSeen ? null : onUnlock,
                child: (profile.phone != null && profile.phone!.isNotEmpty)
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (profile.isSeen) Icon(Icons.phone_outlined, size: 16, color: Colors.grey[400]),
                          if (profile.isSeen) const SizedBox(width: 8),
                          Flexible(
                            child: _buildSelectableTelText(profile.phone!, isEnabled: profile.isSeen),
                          ),
                        ],
                      )
                    : Text('Soon', style: TextStyle(color: Colors.grey[400])),
              );
              break;
            case 'website':
              child = BlurredContentWidget(
                isUnlocked: profile.isSeen,
                unlockCost: profile.unlockCost,
                currentBalance: balance,
                onUnlock: profile.isSeen ? null : onUnlock,
                child: profile.website != null && profile.website!.isNotEmpty
                    ? InkWell(
                        onTap: profile.isSeen ? () => _launchUrl(profile.website) : null,
                        child: Text(
                          profile.website!,
                          style: TextStyle(
                            color: profile.isSeen ? Colors.blue : Colors.grey[400],
                            decoration: profile.isSeen ? TextDecoration.underline : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : Text('Soon', style: TextStyle(color: Colors.grey[400])),
              );
              break;
            case 'actions':
              child = profile.isSeen
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
                    );
              break;
            default:
              child = const SizedBox();
          }
          return Expanded(
            flex: flex,
            child: Center(
              child: child,
            ),
          );
        }).toList(),
      ),
    );
  }
}

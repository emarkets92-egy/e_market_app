import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../../config/theme.dart';
import '../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../features/auth/presentation/cubit/auth_state.dart';

String _formatNumber(int number) {
  final String numberStr = number.toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < numberStr.length; i++) {
    if (i > 0 && (numberStr.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(numberStr[i]);
  }
  return buffer.toString();
}

class PremiumHeaderBar extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onTopUpTap;
  final bool showBackButton;

  const PremiumHeaderBar({super.key, this.onNotificationTap, this.onMenuTap, this.onTopUpTap, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Back button (if enabled) and Premium Access Card
          Row(
            children: [
              if (showBackButton) ...[
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop(), tooltip: 'Back'),
                const SizedBox(width: 8),
              ],
              // Premium Access Card
              BlocBuilder<AuthCubit, AuthState>(
                bloc: di.sl<AuthCubit>(),
                builder: (context, state) {
                  final points = state.user?.points ?? 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.account_balance_wallet, color: AppTheme.primaryBlue, size: 24),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Premium Access',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                                children: [
                                  const TextSpan(text: 'Available Points: '),
                                  TextSpan(
                                    text: _formatNumber(points),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          // Right side: Notification, Menu, Top Up Button
          Row(
            children: [
              IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: onNotificationTap ?? () {}, tooltip: 'Notifications'),
              IconButton(icon: const Icon(Icons.menu), onPressed: onMenuTap ?? () {}, tooltip: 'Menu'),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onTopUpTap ?? () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Top Up Points'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

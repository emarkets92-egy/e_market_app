import 'dart:ui';
import 'package:flutter/material.dart';
import 'unlock_button.dart';

class BlurredContentWidget extends StatelessWidget {
  final bool isUnlocked;
  final Widget child;
  final VoidCallback? onUnlock;
  final int unlockCost;
  final int currentBalance;

  const BlurredContentWidget({
    super.key,
    required this.isUnlocked,
    required this.child,
    this.onUnlock,
    required this.unlockCost,
    required this.currentBalance,
  });

  @override
  Widget build(BuildContext context) {
    if (isUnlocked) {
      return child;
    }

    return Stack(
      children: [
        child,
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Unlock for $unlockCost credits',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              UnlockButton(
                cost: unlockCost,
                currentBalance: currentBalance,
                onUnlock: onUnlock ?? () {},
              ),
              if (currentBalance < unlockCost)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Insufficient balance',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}


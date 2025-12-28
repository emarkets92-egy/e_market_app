import 'dart:ui';
import 'package:flutter/material.dart';

class BlurredContentWidget extends StatelessWidget {
  final bool isUnlocked;
  final Widget child;
  final VoidCallback? onUnlock;
  final int unlockCost;
  final int currentBalance;

  const BlurredContentWidget({super.key, required this.isUnlocked, required this.child, this.onUnlock, required this.unlockCost, required this.currentBalance});

  @override
  Widget build(BuildContext context) {
    if (isUnlocked) {
      return child;
    }

    // For locked content, show blurred version with unlock button visible
    return Stack(
      children: [
        // Blurred content
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.white.withValues(alpha: 0.7), child: child),
          ),
        ),
        // Overlay to make it more blurred
        Container(color: Colors.black.withValues(alpha: 0.2)),
      ],
    );
  }
}

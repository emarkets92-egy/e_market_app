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

    // For locked content, blur the child *without changing its layout*.
    // Using BackdropFilter here can create inconsistent sizing/painting in tight table cells.
    return Stack(
      children: [
        ClipRect(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: child,
          ),
        ),
        // Dim/veil overlay; must fill the same bounds as the content.
        Positioned.fill(
          child: ColoredBox(
            color: Colors.white.withValues(alpha: 0.70),
          ),
        ),
      ],
    );
  }
}

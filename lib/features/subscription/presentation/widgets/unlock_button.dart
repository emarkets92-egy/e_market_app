import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class UnlockButton extends StatelessWidget {
  final int cost;
  final int currentBalance;
  final VoidCallback onUnlock;
  final bool isLoading;

  const UnlockButton({super.key, required this.cost, required this.currentBalance, required this.onUnlock, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final canUnlock = currentBalance >= cost && !isLoading;

    return ElevatedButton(
      onPressed: canUnlock ? onUnlock : null,
      child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text('unlock_credits'.tr(namedArgs: {'cost': cost.toString()})),
    );
  }
}

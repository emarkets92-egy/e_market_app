import 'package:flutter/material.dart';

class UnreadBadge extends StatelessWidget {
  final int count;
  final double? size;

  const UnreadBadge({
    super.key,
    required this.count,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    final badgeSize = size ?? 20.0;
    final text = count > 99 ? '99+' : count.toString();

    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: badgeSize * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

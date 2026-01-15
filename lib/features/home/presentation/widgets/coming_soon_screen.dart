import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? description;

  const ComingSoonScreen({super.key, required this.title, required this.icon, this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(color: AppTheme.lightBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 60, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              description ?? 'We\'re working on something amazing!',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.lightBlue),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(color: AppTheme.lightBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.construction, color: AppTheme.primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Under Development',
                    style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

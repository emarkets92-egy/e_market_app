import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/app_config.dart';

/// Wraps the app and shows a blocking overlay when the viewport is not in
/// desktop layout (width < [AppConfig.desktopMinWidth]). Disables interaction
/// and displays a message that mobile layout is not ready.
class DesktopOnlyWrapper extends StatelessWidget {
  const DesktopOnlyWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktopLayout = width >= AppConfig.desktopMinWidth;

    if (isDesktopLayout) {
      return child;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned.fill(
          child: Material(
            color: Colors.black54,
            child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.desktop_windows,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'desktop_only_title'.tr(),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'desktop_only_message'.tr(),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ],
    );
  }
}

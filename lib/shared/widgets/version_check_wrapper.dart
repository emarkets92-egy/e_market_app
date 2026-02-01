import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection_container.dart' as di;
import '../../features/version/presentation/cubit/version_cubit.dart';
import '../../features/version/presentation/cubit/version_state.dart';
import '../../features/version/presentation/screens/update_required_screen.dart';
import 'startup_loading_screen.dart';

class VersionCheckWrapper extends StatefulWidget {
  final Widget child;

  const VersionCheckWrapper({super.key, required this.child});

  @override
  State<VersionCheckWrapper> createState() => _VersionCheckWrapperState();
}

class _VersionCheckWrapperState extends State<VersionCheckWrapper> {
  @override
  void initState() {
    super.initState();
    // Check version immediately on app start (before showing the app UI).
    Future.microtask(() => di.sl<VersionCubit>().checkVersion());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VersionCubit, VersionState>(
      bloc: di.sl<VersionCubit>(),
      builder: (context, state) {
        // If update is required, show update screen and block app
        if (state is VersionUpdateRequired) {
          return UpdateRequiredScreen(state: state);
        }

        // On startup, render a white loading screen immediately.
        if (state is VersionInitial || state is VersionChecking) {
          return StartupLoadingScreen(message: 'Checking for updates…');
        }

        // If error, block the app (mandatory update)
        if (state is VersionCheckError) {
          return Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('unable_to_check_updates'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        'check_internet_connection'.tr(),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          di.sl<VersionCubit>().checkVersion();
                        },
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // If up to date, show the app
        return widget.child;
      },
    );
  }
}

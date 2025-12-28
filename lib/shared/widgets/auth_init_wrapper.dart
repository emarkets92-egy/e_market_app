import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection_container.dart' as di;
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../config/routes/route_names.dart';

class AuthInitWrapper extends StatefulWidget {
  final Widget child;

  const AuthInitWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AuthInitWrapper> createState() => _AuthInitWrapperState();
}

class _AuthInitWrapperState extends State<AuthInitWrapper> {
  bool _isInitialCheck = true;

  @override
  void initState() {
    super.initState();
    // Call checkAuthStatus on app start to fetch profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      di.sl<AuthCubit>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      bloc: di.sl<AuthCubit>(),
      builder: (context, state) {
        // Show loading screen during initial auth check
        // Continue showing until checkAuthStatus completes and we have a definitive auth state
        if (_isInitialCheck) {
          // Once loading completes (either user loaded or confirmed not authenticated), mark initial check as done
          // Add a small delay to ensure router has time to process navigation and avoid black screen flash
          if (!state.isLoading) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) {
                setState(() {
                  _isInitialCheck = false;
                });
              }
            });
          }
          
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return BlocListener<AuthCubit, AuthState>(
          bloc: di.sl<AuthCubit>(),
          listener: (context, state) {
            // If user becomes unauthenticated, navigate to login
            // The router redirect will handle preventing duplicate navigation
            if (!state.isAuthenticated && state.user == null && context.mounted) {
              // Use post-frame callback to ensure router is available
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  try {
                    // Check if GoRouter is available in context
                    final router = GoRouter.of(context);
                    // Get current location from the router state
                    final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
                    // Only navigate if we're not already on login or register page
                    if (currentLocation != RouteNames.login && 
                        currentLocation != RouteNames.register &&
                        currentLocation != RouteNames.completeProfile) {
                      router.go(RouteNames.login);
                    }
                  } catch (e) {
                    // If router is not available yet, try to navigate after a short delay
                    // This handles the case where router is not initialized yet
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (context.mounted) {
                        try {
                          final router = GoRouter.of(context);
                          router.go(RouteNames.login);
                        } catch (e2) {
                          // If still not available, the redirect in app_router.dart
                          // will handle navigation when the router is ready
                          print('GoRouter not available yet, redirect will handle navigation');
                        }
                      }
                    });
                  }
                }
              });
            }
          },
          child: widget.child,
        );
      },
    );
  }
}


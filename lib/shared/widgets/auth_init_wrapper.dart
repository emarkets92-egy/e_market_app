import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection_container.dart' as di;
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../config/routes/route_names.dart';

class AuthInitWrapper extends StatefulWidget {
  final Widget child;

  const AuthInitWrapper({super.key, required this.child});

  @override
  State<AuthInitWrapper> createState() => _AuthInitWrapperState();
}

class _AuthInitWrapperState extends State<AuthInitWrapper> {
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
    return BlocListener<AuthCubit, AuthState>(
      bloc: di.sl<AuthCubit>(),
      listener: (context, state) {
        if (!context.mounted) return;

        // If user becomes unauthenticated, navigate to login
        if (!state.isAuthenticated && state.user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              try {
                final router = GoRouter.of(context);
                final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
                if (currentLocation != RouteNames.login && 
                    currentLocation != RouteNames.register && 
                    currentLocation != RouteNames.completeProfile) {
                  router.go(RouteNames.login);
                }
              } catch (e) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (context.mounted) {
                    try {
                      final router = GoRouter.of(context);
                      router.go(RouteNames.login);
                    } catch (e2) {
                      // Do nothing
                    }
                  }
                });
              }
            }
          });
          return;
        }

        // If user is authenticated, check subscription status and redirect accordingly
        if (state.isAuthenticated && state.user != null && context.mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              try {
                final router = GoRouter.of(context);
                final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
                
                // Skip redirect if already on appropriate route
                final isLoginRoute = currentLocation == RouteNames.login || currentLocation == RouteNames.register;
                final isCompleteProfileRoute = currentLocation == RouteNames.completeProfile;
                final isSalesRequestRoute = currentLocation == RouteNames.salesRequestCreate || 
                                            currentLocation == RouteNames.salesRequestList ||
                                            currentLocation.startsWith('/sales-requests/');
                
                if (isLoginRoute || isCompleteProfileRoute) {
                  // User just logged in/registered - redirect based on subscription
                  if (state.user!.isUserSubscribed) {
                    router.go(RouteNames.home);
                  } else {
                    router.go(RouteNames.salesRequestCreate);
                  }
                } else if (!state.user!.isUserSubscribed && !isSalesRequestRoute && currentLocation != RouteNames.home) {
                  // User is not subscribed and not on sales request flow - redirect to sales request
                  router.go(RouteNames.salesRequestCreate);
                } else if (state.user!.isUserSubscribed && isSalesRequestRoute) {
                  // User is subscribed but on sales request route - redirect to home
                  router.go(RouteNames.home);
                }
              } catch (e) {
                // Router not available yet, ignore
              }
            }
          });
        }
      },
      child: widget.child,
    );
  }
}

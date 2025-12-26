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
        // If user becomes unauthenticated, navigate to login
        // The router redirect will handle preventing duplicate navigation
        if (!state.isAuthenticated && state.user == null && context.mounted) {
          context.go(RouteNames.login);
        }
      },
      child: widget.child,
    );
  }
}


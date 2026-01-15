import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../../../../config/theme.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/login_form.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        bloc: di.sl<AuthCubit>(),
        listener: (context, state) {
          if (state.isAuthenticated) {
            context.go(RouteNames.home);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingIndicator();
          }

          // Responsive layout: side-by-side on desktop only, form only on mobile
          final isDesktop = MediaQuery.of(context).size.width > 900;

          if (isDesktop) {
            return Row(
              children: [
                // Left Column - Blue Background with Content (Desktop only)
                Expanded(flex: 1, child: _buildLeftColumn(context)),
                // Right Column - Login Form
                Expanded(flex: 1, child: _buildRightColumn(context)),
              ],
            );
          } else {
            // Mobile/Tablet: Show form only, no left column
            return _buildRightColumn(context);
          }
        },
      ),
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    return Container(
      color: AppTheme.primaryBlue,
      child: Stack(
        children: [
          // Background image placeholder - using gradient for now
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withValues(alpha: 0.8)],
              ),
            ),
          ),
          // Content overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.public, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'E Market',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Main heading
                  const Text(
                    'Access Global Export\nOpportunities',
                    style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  const SizedBox(height: 24),
                  // Description
                  Text(
                    'Connect with verified importers worldwide and scale your business beyond borders with our trusted platform.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 18, height: 1.5),
                  ),
                  const SizedBox(height: 48),
                  // Social proof
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(radius: 22, backgroundColor: Colors.blue[300]),
                          ),
                          Positioned(
                            left: 32,
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(radius: 22, backgroundColor: Colors.green[300]),
                            ),
                          ),
                          Positioned(
                            left: 64,
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(radius: 22, backgroundColor: Colors.orange[300]),
                            ),
                          ),
                          Positioned(
                            left: 96,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  '+2k',
                                  style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Text('trusted_by_exporters'.tr(), style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: SingleChildScrollView(
          child: LoginForm(
            onLogin: (email, password) {
              di.sl<AuthCubit>().login(email, password);
            },
          ),
        ),
      ),
    );
  }
}

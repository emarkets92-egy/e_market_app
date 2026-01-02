import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../../../../config/theme.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../widgets/sidebar_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Only check auth status if user is not already loaded (avoid redundant calls)
    final authState = di.sl<AuthCubit>().state;
    if (authState.user == null && !authState.isLoading) {
      di.sl<AuthCubit>().checkAuthStatus();
    }
    // Load subscriptions
    di.sl<SubscriptionCubit>().getSubscriptions(activeOnly: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          const SidebarNavigation(hasUnreadNotifications: false),

          // Main Content Area
          Expanded(
            child: BlocBuilder<AuthCubit, AuthState>(
              bloc: di.sl<AuthCubit>(),
              builder: (context, authState) {
                // Only show loading if user is null and we're actively loading
                // This prevents showing loading when user is already loaded from initial check
                if (authState.user == null && authState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // If user is null but not loading, something went wrong - show error or redirect
                if (authState.user == null) {
                  return const Center(child: Text('Unable to load user. Please try again.'));
                }

                return Column(
                  children: [
                    // Top Header
                    _TopHeader(),

                    // Main Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome Section
                            _WelcomeSection(userName: authState.user?.name ?? 'Exporter'),

                            const SizedBox(height: 32),

                            // Export Products Card
                            _ExportProductsCard(
                              onTap: () {
                                context.push(RouteNames.subscriptionSelection);
                              },
                            ),

                            const SizedBox(height: 32),

                            // Service Cards
                            const _ServiceCards(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await di.sl<AuthCubit>().logout();
              if (context.mounted) {
                context.go(RouteNames.login);
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final String userName;

  const _WelcomeSection({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              children: [
                const TextSpan(
                  text: 'Welcome back, ',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                TextSpan(
                  text: '$userName.',
                  style: const TextStyle(color: AppTheme.primaryBlue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your gateway to global trade. Manage your products and discover new\nopportunities seamlessly.',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ExportProductsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ExportProductsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E7FF), // Light indigo/blue
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
                child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 10),
              const Text(
                'Export Products',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Text(
                  'Manage your inventory, update listings, and prepare shipments for global delivery with our comprehensive tools.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCards extends StatelessWidget {
  const _ServiceCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ServiceCardItem(
            title: 'Marketing Plan',
            description: 'We help you build a sales and marketing plan tailored to your product and target markets.',
            icon: Icons.verified_user_outlined,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _ServiceCardItem(
            title: 'Market Analysis',
            description: 'SWOT and PESTEL analysis plus competitive insights to enter markets confidently.',
            icon: Icons.analytics_outlined,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _ServiceCardItem(
            title: 'Target Market',
            description: 'Identify the countries with the highest demand for your product using HS Codes and data analysis',
            icon: Icons.public,
          ),
        ),
      ],
    );
  }
}

class _ServiceCardItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _ServiceCardItem({required this.title, required this.description, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Very light blue
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.lightBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

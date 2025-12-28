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

String _formatNumber(int number) {
  final String numberStr = number.toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < numberStr.length; i++) {
    if (i > 0 && (numberStr.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(numberStr[i]);
  }
  return buffer.toString();
}

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
          const SidebarNavigation(
            hasUnreadNotifications: false,
          ),
          
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
                  return const Center(
                    child: Text('Unable to load user. Please try again.'),
                  );
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
                            
                            // Recent Market Activity
                            _RecentMarketActivity(),
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
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BlocBuilder<AuthCubit, AuthState>(
            bloc: di.sl<AuthCubit>(),
            builder: (context, state) {
              final points = state.user?.points ?? 0;
              return Row(
                children: [
                  const Icon(Icons.stars, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Points: ${_formatNumber(points)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 24),
          Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Gold Member',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            children: [
              const TextSpan(text: 'Welcome back, '),
              TextSpan(
                text: userName,
                style: const TextStyle(color: AppTheme.primaryBlue),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your gateway to global trade. Manage your products and discover new opportunities seamlessly.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _ExportProductsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ExportProductsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Export Products',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Manage your inventory, update listings, and prepare shipments for global delivery with our comprehensive tools.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.lightBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentMarketActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Text(
                  'Recent Market Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.trending_up,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View Report',
                style: TextStyle(color: AppTheme.lightBlue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'TOTAL REVENUE',
                value: '\$124,500',
                trend: '+12%',
                trendColor: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                label: 'ACTIVE SHIPMENTS',
                value: '42',
                subtitle: 'Processing',
                trend: null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _LiveTrackerCard(),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final String? trend;
  final Color? trendColor;

  const _StatCard({
    required this.label,
    required this.value,
    this.subtitle,
    this.trend,
    this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              if (trend != null) ...[
                const SizedBox(width: 8),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 16,
                      color: trendColor ?? Colors.green,
                    ),
                    Text(
                      trend!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: trendColor ?? Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LiveTrackerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Stack(
        children: [
          // Placeholder for map
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.public,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Live Tracker'),
            ),
          ),
        ],
      ),
    );
  }
}

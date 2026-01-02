import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../config/theme.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class SidebarNavigation extends StatelessWidget {
  final bool hasUnreadNotifications;

  const SidebarNavigation({super.key, this.hasUnreadNotifications = false});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Container(
      width: 240,
      color: Colors.white,
      child: Column(
        children: [
          // Logo Section
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [SizedBox(width: 100, height: 100, child: Image.asset('assets/logo 1.png', fit: BoxFit.contain))],
            ),
          ),
          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _NavItem(icon: Icons.home, label: 'Home', isActive: currentRoute == RouteNames.home, onTap: () => context.go(RouteNames.home)),
                _NavItem(
                  icon: Icons.inbox,
                  label: 'Inbox',
                  isActive: currentRoute == RouteNames.inbox,
                  hasNotification: hasUnreadNotifications,
                  onTap: () => context.go(RouteNames.inbox),
                ),
                _NavItem(
                  icon: Icons.lightbulb_outline,
                  label: 'Opportunities',
                  isActive: currentRoute == RouteNames.opportunities,
                  onTap: () => context.go(RouteNames.opportunities),
                ),
                _NavItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  isActive: currentRoute == RouteNames.notifications,
                  onTap: () => context.go(RouteNames.notifications),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  isActive: currentRoute == RouteNames.profile,
                  onTap: () => context.go(RouteNames.profile),
                ),
              ],
            ),
          ),

          // User Profile Section
          BlocBuilder<AuthCubit, AuthState>(
            bloc: di.sl<AuthCubit>(),
            builder: (context, state) {
              final user = state.user;
              if (user == null) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.lightBlue,
                      child: Text(
                        (user.name ?? user.email)[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name ?? user.email,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text('Premium Plan', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool hasNotification;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isActive, this.hasNotification = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: isActive ? AppTheme.lightBlue.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, color: isActive ? AppTheme.primaryBlue : Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? AppTheme.primaryBlue : Colors.grey[700],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
            if (hasNotification)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}

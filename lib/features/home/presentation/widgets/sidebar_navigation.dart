import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../config/theme.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../chat/presentation/cubit/chat_cubit.dart';
import '../../../chat/presentation/cubit/chat_state.dart';
import '../../../chat/presentation/widgets/unread_badge.dart';
import '../../../../shared/widgets/about_us_section.dart';
import '../../../../shared/widgets/contact_us_section.dart';

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
              children: [SizedBox(width: 180, height: 180, child: Image.asset('assets/logo 1.png', fit: BoxFit.contain))],
            ),
          ),
          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _NavItem(
                  icon: Icons.home,
                  label: 'home'.tr(),
                  isActive: currentRoute == RouteNames.home,
                  hasNotification: false,
                  onTap: () => context.go(RouteNames.home),
                ),
                BlocBuilder<ChatCubit, ChatState>(
                  bloc: di.sl<ChatCubit>(),
                  builder: (context, chatState) {
                    final totalUnread = chatState.totalUnread;
                    return _NavItem(
                      icon: Icons.inbox,
                      label: 'inbox'.tr(),
                      isActive: currentRoute == RouteNames.inbox,
                      hasNotification: totalUnread > 0,
                      unreadCount: totalUnread > 0 ? totalUnread : null,
                      onTap: () {
                        context.go(RouteNames.inbox);
                        // Load conversations when navigating
                        di.sl<ChatCubit>().loadConversations();
                        di.sl<ChatCubit>().getUnseenMessages();
                      },
                    );
                  },
                ),
                const Divider(height: 1),
                _NavItem(
                  icon: Icons.info_outline,
                  label: 'about_us'.tr(),
                  isActive: false,
                  hasNotification: false,
                  onTap: () {
                    _showAboutUsDialog(context);
                  },
                ),
                _NavItem(
                  icon: Icons.contact_mail_outlined,
                  label: 'contact_us'.tr(),
                  isActive: false,
                  hasNotification: false,
                  onTap: () {
                    _showContactUsDialog(context);
                  },
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
                          Text('premium_plan'.tr(), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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

  void _showAboutUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text('about_us'.tr()),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: const AboutUsSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text('contact_us'.tr()),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: const ContactUsSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool hasNotification;
  final int? unreadCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.hasNotification,
    this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: isActive ? AppTheme.lightBlue.withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
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
              unreadCount != null && unreadCount! > 0
                  ? UnreadBadge(count: unreadCount!)
                  : Container(
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

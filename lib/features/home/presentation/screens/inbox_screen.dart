import 'package:flutter/material.dart';
import '../widgets/sidebar_navigation.dart';
import '../widgets/coming_soon_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SidebarNavigation(hasUnreadNotifications: true),
          const Expanded(
            child: ComingSoonScreen(title: 'Inbox', icon: Icons.inbox, description: 'Your messages and communications will appear here soon.'),
          ),
        ],
      ),
    );
  }
}

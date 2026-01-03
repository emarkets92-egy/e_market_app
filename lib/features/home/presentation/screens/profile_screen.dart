import 'package:flutter/material.dart';
import '../widgets/sidebar_navigation.dart';
import '../widgets/coming_soon_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SidebarNavigation(),
          const Expanded(
            child: ComingSoonScreen(title: 'Profile', icon: Icons.person_outline, description: 'Manage your account settings and preferences coming soon.'),
          ),
        ],
      ),
    );
  }
}

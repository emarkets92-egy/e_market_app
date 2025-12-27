import 'package:flutter/material.dart';
import '../widgets/sidebar_navigation.dart';
import '../widgets/coming_soon_screen.dart';

class OpportunitiesScreen extends StatelessWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SidebarNavigation(),
          const Expanded(
            child: ComingSoonScreen(
              title: 'Opportunities',
              icon: Icons.lightbulb_outline,
              description: 'Discover new market opportunities and business prospects coming soon.',
            ),
          ),
        ],
      ),
    );
  }
}


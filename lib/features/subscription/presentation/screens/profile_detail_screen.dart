import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../../../../config/theme.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../widgets/blurred_content_widget.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../data/models/unlock_item_model.dart';

class ProfileDetailScreen extends StatelessWidget {
  final String profileId;

  const ProfileDetailScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        bloc: di.sl<SubscriptionCubit>(),
        builder: (context, state) {
          // Search in both unseen and seen profiles
          final allProfiles = [
            ...state.unseenProfiles,
            ...state.seenProfiles,
          ];

          if (allProfiles.isEmpty) {
            return const Center(child: Text('Profile not found'));
          }

          final profile = allProfiles.firstWhere(
            (p) => p.id == profileId,
            orElse: () => allProfiles.first, // Fallback to first profile
          );

          return Column(
            children: [
              // Header with logo, notifications, and user info
              _buildHeader(context),
              
              // Breadcrumb navigation
              _buildBreadcrumb(context),
              
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Company info
                        Expanded(
                          flex: 2,
                          child: _buildLeftColumn(context, profile),
                        ),
                        const SizedBox(width: 24),
                        // Right column - Stats and Import History
                        Expanded(
                          flex: 3,
                          child: _buildRightColumn(context, profile),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // E Market Logo
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.public,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'E Market',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          // Right side - Notifications and user
          BlocBuilder<AuthCubit, AuthState>(
            bloc: di.sl<AuthCubit>(),
            builder: (context, authState) {
              final userName = authState.user?.name ?? 'User';
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      context.push(RouteNames.notifications);
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryBlue,
                    child: Text(
                      userName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(RouteNames.home),
            child: const Text(
              'Home',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontSize: 14,
              ),
            ),
          ),
          const Text(' / ', style: TextStyle(color: Colors.grey)),
          GestureDetector(
            onTap: () => context.pop(),
            child: const Text(
              'Importers Directory',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontSize: 14,
              ),
            ),
          ),
          const Text(' / ', style: TextStyle(color: Colors.grey)),
          const Text(
            'Global Traders Ltd.',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn(BuildContext context, profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company Overview
        _buildCompanyOverview(context, profile),
        const SizedBox(height: 24),
        // Contact Information
        _buildContactInformation(context, profile),
        const SizedBox(height: 24),
        // Target Markets
        _buildTargetMarkets(context),
        const SizedBox(height: 24),
        // HS Codes Handled
        _buildHSCodes(context),
        const SizedBox(height: 24),
        // View Full Company Profile
        _buildViewFullProfile(context),
        const SizedBox(height: 24),
        // Map
        _buildMap(context),
      ],
    );
  }

  Widget _buildCompanyOverview(BuildContext context, profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.business,
              size: 40,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          // Company Name
          const Text(
            'Global Traders Ltd.',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          // Gold Tier Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium, size: 16, color: Colors.amber[700]),
                const SizedBox(width: 6),
                const Text(
                  'GOLD TIER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Country and Member Since
          Row(
            children: [
              const Icon(Icons.public, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'United States',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(width: 24),
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Member since 2018',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInformation(BuildContext context, profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactItem(Icons.email_outlined, 'EMAIL ADDRESS', profile.email ?? 'contact@globaltraders.com'),
          const SizedBox(height: 16),
          _buildContactItem(Icons.phone_outlined, 'PHONE NUMBER', profile.phone ?? '+1 555-0199'),
          const SizedBox(height: 16),
          _buildContactItem(Icons.business_outlined, 'COMPANY TYPE', 'Private Limited'),
          const SizedBox(height: 16),
          _buildContactItem(Icons.location_on_outlined, 'HEADQUARTERS', profile.address ?? 'New York, NY 10001'),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTargetMarkets(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Target Markets',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPillButton('North America'),
              _buildPillButton('Europe'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHSCodes(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HS Codes Handled',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPillButton('8517.12'),
              _buildPillButton('8517.62'),
              _buildPillButton('8504.40'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildViewFullProfile(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: const Text(
        'View Full Company Profile →',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          // Placeholder for map
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'New York Office',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Map pin
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primaryBlue, size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    'New York Office',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightColumn(BuildContext context, profile) {
    final balance = _getCurrentBalance(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Buttons
        Row(
          children: [
            _buildActionButton(
              icon: Icons.favorite_outline,
              label: 'Save',
              onPressed: () {},
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              icon: Icons.share_outlined,
              label: 'Share',
              onPressed: () {},
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.message_outlined),
                label: const Text('Send Message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Key Statistics
        _buildKeyStatistics(context),
        const SizedBox(height: 24),
        // Import History
        _buildImportHistory(context, profile, balance),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildKeyStatistics(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'TOTAL IMPORTS',
            value: '1,245',
            trend: '+12% this year',
            trendColor: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            label: 'TOP ORIGIN',
            value: 'China',
            icon: Icons.flag,
            iconColor: Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            label: 'AVG. VOLUME',
            value: '\$45k',
            subtitle: 'Per shipment',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            label: 'RELIABILITY',
            value: '98%',
            subtitle: 'On-time payments',
            valueColor: AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    String? subtitle,
    String? trend,
    Color? trendColor,
    IconData? icon,
    Color? iconColor,
    Color? valueColor,
  }) {
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
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: iconColor ?? Colors.grey),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ),
              if (trend != null) ...[
                const SizedBox(width: 8),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 14,
                      color: trendColor ?? Colors.green,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 12,
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
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImportHistory(BuildContext context, profile, int balance) {
    final isUnlocked = profile.isSeen;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Import History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recent shipments and transaction records',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: const Text('Filter'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Export'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Import History Content with Unlock Overlay
          SizedBox(
            height: 400,
            child: Stack(
              children: [
                BlurredContentWidget(
                  isUnlocked: isUnlocked,
                  unlockCost: profile.unlockCost,
                  currentBalance: balance,
                  onUnlock: isUnlocked
                      ? null
                      : () {
                          di.sl<SubscriptionCubit>().unlock(
                            contentType: ContentType.profileContact,
                            targetId: profile.id,
                          );
                        },
                  child: _buildImportHistoryContent(context, profile),
                ),
                // Unlock overlay
                if (!isUnlocked)
                  _buildUnlockOverlay(context, profile, balance),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportHistoryContent(BuildContext context, profile) {
    return GestureDetector(
      onTap: () {
        if (profile.isSeen) {
          context.push(
            RouteNames.shipmentRecordsList.replaceAll(':profileId', profile.id),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_shipping,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Click to view shipment records',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnlockOverlay(BuildContext context, profile, int balance) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Unlock Full Import History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Spend ${profile.unlockCost} credit${profile.unlockCost != 1 ? 's' : ''} to reveal detailed shipment records, supplier info, HS codes, and product specifications for this importer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: balance >= profile.unlockCost
                    ? () {
                        di.sl<SubscriptionCubit>().unlock(
                          contentType: ContentType.profileContact,
                          targetId: profile.id,
                        );
                      }
                    : null,
                icon: const Icon(Icons.vpn_key),
                label: Text('Unlock for ${profile.unlockCost} Credit${profile.unlockCost != 1 ? 's' : ''}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You have $balance credit${balance != 1 ? 's' : ''} remaining in your balance.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getCurrentBalance(BuildContext context) {
    try {
      return context.read<AuthCubit>().state.user?.points ?? 0;
    } catch (e) {
      return di.sl<AuthCubit>().state.user?.points ?? 0;
    }
  }
}

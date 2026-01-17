import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../../../../config/theme.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../../../locale/presentation/cubit/locale_cubit.dart';
import '../../../locale/presentation/cubit/locale_state.dart';
import '../../../notifications/presentation/cubit/notification_cubit.dart';
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
    // Load notifications unread count
    di.sl<NotificationCubit>().getUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          const SidebarNavigation(),

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
                  return Center(child: Text('unable_to_load_user'.tr()));
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
                            _WelcomeSection(userName: authState.user?.name ?? 'exporter'.tr()),

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
  const _TopHeader();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Language Switcher
          BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              final currentLocale = localeState.locale;
              return PopupMenuButton<String>(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language, color: AppTheme.primaryBlue),
                    const SizedBox(width: 4),
                    Text(
                      _getLanguageName(context, currentLocale.languageCode),
                      style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                tooltip: 'select_language'.tr(),
                onSelected: (String languageCode) {
                  context.read<LocaleCubit>().changeLocaleByCode(languageCode);
                },
                itemBuilder: (BuildContext context) {
                  final locale = localeState.locale;
                  return [
                    PopupMenuItem<String>(
                      value: 'en',
                      child: Row(
                        children: [
                          if (locale.languageCode == 'en') const Icon(Icons.check, color: AppTheme.primaryBlue, size: 20),
                          if (locale.languageCode == 'en') const SizedBox(width: 8),
                          Text('english'.tr()),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'ar',
                      child: Row(
                        children: [
                          if (locale.languageCode == 'ar') const Icon(Icons.check, color: AppTheme.primaryBlue, size: 20),
                          if (locale.languageCode == 'ar') const SizedBox(width: 8),
                          Text('arabic'.tr()),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'fr',
                      child: Row(
                        children: [
                          if (locale.languageCode == 'fr') const Icon(Icons.check, color: AppTheme.primaryBlue, size: 20),
                          if (locale.languageCode == 'fr') const SizedBox(width: 8),
                          Text('french'.tr()),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'it',
                      child: Row(
                        children: [
                          if (locale.languageCode == 'it') const Icon(Icons.check, color: AppTheme.primaryBlue, size: 20),
                          if (locale.languageCode == 'it') const SizedBox(width: 8),
                          Text('italian'.tr()),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'es',
                      child: Row(
                        children: [
                          if (locale.languageCode == 'es') const Icon(Icons.check, color: AppTheme.primaryBlue, size: 20),
                          if (locale.languageCode == 'es') const SizedBox(width: 8),
                          Text('spanish'.tr()),
                        ],
                      ),
                    ),
                  ];
                },
              );
            },
          ),
          const SizedBox(width: 8),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await di.sl<AuthCubit>().logout();
              if (context.mounted) {
                context.go(RouteNames.login);
              }
            },
            tooltip: 'logout'.tr(),
          ),
        ],
      ),
    );
  }
  
  String _getLanguageName(BuildContext context, String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'english'.tr();
      case 'ar':
        return 'arabic'.tr();
      case 'fr':
        return 'french'.tr();
      case 'it':
        return 'italian'.tr();
      case 'es':
        return 'spanish'.tr();
      default:
        return 'english'.tr();
    }
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
                TextSpan(
                  text: '${'welcome_back'.tr()}, ',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black),
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
            'gateway_to_global_trade'.tr(),
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
              Text(
                'start'.tr(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Text(
                  'manage_inventory_description'.tr(),
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
            title: 'marketing_plan'.tr(),
            description: 'marketing_plan_description'.tr(),
            icon: Icons.verified_user_outlined,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _ServiceCardItem(
            title: 'market_analysis'.tr(),
            description: 'market_analysis_description'.tr(),
            icon: Icons.analytics_outlined,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _ServiceCardItem(
            title: 'target_market'.tr(),
            description: 'target_market_description'.tr(),
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
            decoration: BoxDecoration(color: AppTheme.lightBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
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

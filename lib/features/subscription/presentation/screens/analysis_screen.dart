import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/theme.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../localization/presentation/cubit/localization_cubit.dart';
import '../../../localization/data/models/country_model.dart';
import '../widgets/blurred_content_widget.dart';
import '../widgets/unlock_button.dart';
import '../../data/models/unlock_item_model.dart';

enum AnalysisTab { overview, competitiveAnalysis, pestleAnalysis, swotAnalysis, marketPlan }

class AnalysisScreen extends StatefulWidget {
  final String productId;
  final int countryId;

  const AnalysisScreen({super.key, required this.productId, required this.countryId});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  AnalysisTab _selectedTab = AnalysisTab.overview;
  CountryModel? _selectedCountry;

  @override
  void initState() {
    super.initState();
    // If data is not loaded, try to load it (handles direct navigation)
    final currentState = di.sl<SubscriptionCubit>().state;
    if (currentState.marketExploration == null && !currentState.isLoading) {
      di.sl<SubscriptionCubit>().exploreMarket(productId: widget.productId, marketType: 'targetMarkets', countryId: widget.countryId);
    }
    // Load countries to get country name
    _loadCountryInfo();
  }

  Future<void> _loadCountryInfo() async {
    final localizationCubit = di.sl<LocalizationCubit>();
    if (localizationCubit.state.countries.isEmpty) {
      await localizationCubit.loadCountries();
    }
    final country = localizationCubit.state.countries.firstWhere(
      (c) => c.id == widget.countryId,
      orElse: () => CountryModel(id: 0, code: '', name: 'Unknown'),
    );
    if (mounted) {
      setState(() {
        _selectedCountry = country.id != 0 ? country : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        bloc: di.sl<SubscriptionCubit>(),
        builder: (context, state) {
          // Show loading indicator while fetching
          if (state.isLoading && state.marketExploration == null) {
            return const LoadingIndicator(message: 'Loading analysis data...');
          }

          // Show error if there's an error and no data
          if (state.error != null && state.marketExploration == null) {
            return AppErrorWidget(
              message: state.error!,
              onRetry: () {
                di.sl<SubscriptionCubit>().exploreMarket(productId: widget.productId, marketType: 'targetMarkets', countryId: widget.countryId);
              },
            );
          }

          final exploration = state.marketExploration;
          if (exploration == null) {
            return const Center(child: Text('No analysis data available'));
          }

          return Column(
            children: [
              _buildHeader(context),
              _buildActionButtons(context),
              _buildTargetMarketSelector(context),
              _buildTabNavigation(context, exploration),
              Expanded(child: _buildTabContent(context, exploration)),
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
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button and Logo
              Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                    tooltip: 'Back',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.public, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'GlobalExport Pro',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                  ),
                ],
              ),
              // Right side - Points, Company, Notifications, Profile
              BlocBuilder<AuthCubit, AuthState>(
                bloc: di.sl<AuthCubit>(),
                builder: (context, authState) {
                  final user = authState.user;
                  return Row(
                    children: [
                      // Points
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.stars, color: Colors.amber, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${user?.points ?? 0} Points',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Company Name
                      if (user?.companyName != null)
                        Text(
                          user!.companyName!,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                        ),
                      const SizedBox(width: 16),
                      // Notifications
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {
                          // Handle notifications
                        },
                        tooltip: 'Notifications',
                      ),
                      // Profile
                      GestureDetector(
                        onTap: () {
                          // Handle profile
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.person, color: AppTheme.primaryBlue, size: 20),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              // Handle share
            },
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              // Handle export report
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Export Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetMarketSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          const Text(
            'Selected Target Market:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  if (_selectedCountry?.flagEmoji != null)
                    Text(_selectedCountry!.flagEmoji!, style: const TextStyle(fontSize: 20))
                  else
                    const Icon(Icons.flag, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedCountry != null ? '${_selectedCountry!.name} (Automotive)' : 'Loading...',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation(BuildContext context, dynamic exploration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTab(context, 'Overview', AnalysisTab.overview, exploration.marketPlan != null),
            const SizedBox(width: 8),
            _buildTab(context, 'Competitive Analysis', AnalysisTab.competitiveAnalysis, exploration.competitiveAnalysis != null),
            const SizedBox(width: 8),
            _buildTab(context, 'PESTLE Analysis', AnalysisTab.pestleAnalysis, exploration.pestleAnalysis != null),
            const SizedBox(width: 8),
            _buildTab(context, 'SWOT Analysis', AnalysisTab.swotAnalysis, exploration.swotAnalysis != null),
            const SizedBox(width: 8),
            _buildTab(context, 'Market Plan', AnalysisTab.marketPlan, exploration.marketPlan != null),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, AnalysisTab tab, bool isAvailable) {
    final isSelected = _selectedTab == tab;
    return GestureDetector(
      onTap: isAvailable
          ? () {
              setState(() {
                _selectedTab = tab;
              });
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: isSelected ? AppTheme.primaryBlue : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : isAvailable
                ? Colors.black87
                : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, dynamic exploration) {
    switch (_selectedTab) {
      case AnalysisTab.overview:
        return _buildOverviewTab(context, exploration);
      case AnalysisTab.competitiveAnalysis:
        return _buildCompetitiveAnalysisTab(context, exploration);
      case AnalysisTab.pestleAnalysis:
        return _buildPESTLEAnalysisTab(context, exploration);
      case AnalysisTab.swotAnalysis:
        return _buildSWOTAnalysisTab(context, exploration);
      case AnalysisTab.marketPlan:
        return _buildMarketPlanTab(context, exploration);
    }
  }

  Widget _buildCompetitiveAnalysisTab(BuildContext context, dynamic exploration) {
    final analysis = exploration.competitiveAnalysis;
    if (analysis == null) {
      return const Center(child: Text('No competitive analysis available'));
    }

    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      bloc: di.sl<SubscriptionCubit>(),
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Competitive Analysis', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Compare the selected country\'s export performance against top global competitors in target markets to identify growth gaps.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(analysis.marketName ?? 'Competitive Analysis', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      BlurredContentWidget(
                        isUnlocked: analysis.isSeen,
                        unlockCost: analysis.unlockCost,
                        currentBalance: _getBalance(context),
                        onUnlock: analysis.isSeen
                            ? null
                            : () {
                                di.sl<SubscriptionCubit>().unlock(contentType: ContentType.competitiveAnalysis, targetId: analysis.id);
                              },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (analysis.totalImports != null) _buildInfoRow('Total Imports', analysis.totalImports!),
                            if (analysis.totalExportsFromSelectedCountry != null) _buildInfoRow('Total Exports', analysis.totalExportsFromSelectedCountry!),
                            if (analysis.rank != null) _buildInfoRow('Rank', '#${analysis.rank}'),
                            if (analysis.totalImports == null && analysis.totalExportsFromSelectedCountry == null && analysis.rank == null)
                              const Text('Analysis data will be available after unlocking'),
                          ],
                        ),
                      ),
                      if (!analysis.isSeen)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: UnlockButton(
                            cost: analysis.unlockCost,
                            currentBalance: _getBalance(context),
                            onUnlock: () {
                              di.sl<SubscriptionCubit>().unlock(contentType: ContentType.competitiveAnalysis, targetId: analysis.id);
                            },
                            isLoading: state.isUnlocking,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPESTLEAnalysisTab(BuildContext context, dynamic exploration) {
    final analysis = exploration.pestleAnalysis;
    if (analysis == null) {
      return const Center(child: Text('No PESTLE analysis available'));
    }

    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      bloc: di.sl<SubscriptionCubit>(),
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PESTLE Analysis', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Comprehensive assessment of Political, Economic, Social, Technological, Legal, and Environmental factors affecting the market.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlurredContentWidget(
                        isUnlocked: analysis.isSeen,
                        unlockCost: analysis.unlockCost,
                        currentBalance: _getBalance(context),
                        onUnlock: analysis.isSeen
                            ? null
                            : () {
                                if (analysis.id != null) {
                                  di.sl<SubscriptionCubit>().unlock(contentType: ContentType.pestleAnalysis, targetId: analysis.id!);
                                }
                              },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (analysis.political != null) _buildSection('Political', analysis.political!),
                            if (analysis.economic != null) _buildSection('Economic', analysis.economic!),
                            if (analysis.social != null) _buildSection('Social', analysis.social!),
                            if (analysis.technological != null) _buildSection('Technological', analysis.technological!),
                            if (analysis.legal != null) _buildSection('Legal', analysis.legal!),
                            if (analysis.environmental != null) _buildSection('Environmental', analysis.environmental!),
                          ],
                        ),
                      ),
                      if (!analysis.isSeen)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: UnlockButton(
                            cost: analysis.unlockCost,
                            currentBalance: _getBalance(context),
                            onUnlock: () {
                              if (analysis.id != null) {
                                di.sl<SubscriptionCubit>().unlock(contentType: ContentType.pestleAnalysis, targetId: analysis.id!);
                              }
                            },
                            isLoading: state.isUnlocking,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSWOTAnalysisTab(BuildContext context, dynamic exploration) {
    final analysis = exploration.swotAnalysis;
    if (analysis == null) {
      return const Center(child: Text('No SWOT analysis available'));
    }

    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      bloc: di.sl<SubscriptionCubit>(),
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SWOT Analysis', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Comprehensive assessment of market viability and strategic positioning.', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlurredContentWidget(
                        isUnlocked: analysis.isSeen,
                        unlockCost: analysis.unlockCost,
                        currentBalance: _getBalance(context),
                        onUnlock: analysis.isSeen
                            ? null
                            : () {
                                if (analysis.id != null) {
                                  di.sl<SubscriptionCubit>().unlock(contentType: ContentType.swotAnalysis, targetId: analysis.id!);
                                }
                              },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (analysis.strengths != null) _buildSection('Strengths', analysis.strengths!),
                            if (analysis.weaknesses != null) _buildSection('Weaknesses', analysis.weaknesses!),
                            if (analysis.opportunities != null) _buildSection('Opportunities', analysis.opportunities!),
                            if (analysis.threats != null) _buildSection('Threats', analysis.threats!),
                          ],
                        ),
                      ),
                      if (!analysis.isSeen)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: UnlockButton(
                            cost: analysis.unlockCost,
                            currentBalance: _getBalance(context),
                            onUnlock: () {
                              if (analysis.id != null) {
                                di.sl<SubscriptionCubit>().unlock(contentType: ContentType.swotAnalysis, targetId: analysis.id!);
                              }
                            },
                            isLoading: state.isUnlocking,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  int _getBalance(BuildContext context) {
    return di.sl<AuthCubit>().state.user?.points ?? 0;
  }

  Widget _buildOverviewTab(BuildContext context, dynamic exploration) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Market Analysis Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Comprehensive market insights for ${_selectedCountry?.name ?? "selected market"}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 24),
          // Analysis Cards Grid
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              if (exploration.competitiveAnalysis != null)
                _buildAnalysisCard(
                  context,
                  'Competitive Analysis',
                  'Compare export performance against competitors',
                  Icons.trending_up,
                  AppTheme.primaryBlue,
                  exploration.competitiveAnalysis!.isSeen,
                  () {
                    setState(() {
                      _selectedTab = AnalysisTab.competitiveAnalysis;
                    });
                  },
                ),
              if (exploration.pestleAnalysis != null)
                _buildAnalysisCard(
                  context,
                  'PESTLE Analysis',
                  'Political, Economic, Social, Technological, Legal, Environmental factors',
                  Icons.assessment,
                  Colors.orange,
                  exploration.pestleAnalysis!.isSeen,
                  () {
                    setState(() {
                      _selectedTab = AnalysisTab.pestleAnalysis;
                    });
                  },
                ),
              if (exploration.swotAnalysis != null)
                _buildAnalysisCard(
                  context,
                  'SWOT Analysis',
                  'Strengths, Weaknesses, Opportunities, and Threats',
                  Icons.insights,
                  Colors.green,
                  exploration.swotAnalysis!.isSeen,
                  () {
                    setState(() {
                      _selectedTab = AnalysisTab.swotAnalysis;
                    });
                  },
                ),
              if (exploration.marketPlan != null)
                _buildAnalysisCard(
                  context,
                  'Market Plan',
                  'Strategic market entry and expansion plan',
                  Icons.business_center,
                  Colors.purple,
                  exploration.marketPlan!.isSeen,
                  () {
                    setState(() {
                      _selectedTab = AnalysisTab.marketPlan;
                    });
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, String title, String description, IconData icon, Color color, bool isUnlocked, VoidCallback onTap) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 600 ? 280 : double.infinity,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const Spacer(),
                    Icon(isUnlocked ? Icons.lock_open : Icons.lock, color: isUnlocked ? Colors.green : Colors.grey, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketPlanTab(BuildContext context, dynamic exploration) {
    final marketPlan = exploration.marketPlan;
    if (marketPlan == null) {
      return const Center(child: Text('No market plan available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Market Plan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (marketPlan.productText != null) _buildPlanSection('Product', marketPlan.productText!),
          if (marketPlan.priceText != null) _buildPlanSection('Price', marketPlan.priceText!),
          if (marketPlan.placeText != null) _buildPlanSection('Place', marketPlan.placeText!),
          if (marketPlan.promotionText != null) _buildPlanSection('Promotion', marketPlan.promotionText!),
        ],
      ),
    );
  }

  Widget _buildPlanSection(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

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
import '../widgets/blurred_content_widget.dart';
import '../widgets/unlock_button.dart';
import '../../data/models/unlock_item_model.dart';

enum AnalysisTab { competitiveAnalysis, pestleAnalysis, swotAnalysis, marketPlan }

class AnalysisScreen extends StatefulWidget {
  final String productId;
  final int countryId;

  const AnalysisScreen({super.key, required this.productId, required this.countryId});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  AnalysisTab _selectedTab = AnalysisTab.competitiveAnalysis;

  @override
  void initState() {
    super.initState();
    // If data is not loaded, try to load it (handles direct navigation)
    final currentState = di.sl<SubscriptionCubit>().state;
    if (currentState.marketExploration == null && !currentState.isLoading) {
      di.sl<SubscriptionCubit>().exploreMarket(productId: widget.productId, marketType: 'targetMarkets', countryId: widget.countryId);
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
                  Image.asset(
                    'assets/logo 1.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
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
            _buildTab(context, 'Overview & Competitive Analysis', AnalysisTab.competitiveAnalysis, exploration.competitiveAnalysis != null),
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
              // Competitive Analysis Section
              const Text('Competitive Analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 800) {
                      return Column(
                        children: [
                          _buildCompetitiveCard('TOTAL IMPORTS', analysis.totalImports ?? 'N/A', Icons.trending_up, Colors.blue),
                          const SizedBox(height: 16),
                          _buildCompetitiveCard('TOTAL IMPORT FROM EGYPT', analysis.totalExportsFromSelectedCountry ?? 'N/A', Icons.flag, Colors.green, rank: analysis.rank),
                          const SizedBox(height: 16),
                          _buildCompetitiveCard('TOP COMPETITOR', analysis.competingCountryName ?? 'N/A', Icons.star, Colors.orange),
                          const SizedBox(height: 16),
                          _buildCompetitiveCard('EXPORT OPPORTUNITY', analysis.competingCountryExports ?? 'N/A', Icons.insights, Colors.purple, subtitle: 'Potential market gap identified', rank: analysis.competingCountryRank != null ? int.tryParse(analysis.competingCountryRank!) : null),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: _buildCompetitiveCard('TOTAL IMPORTS', analysis.totalImports ?? 'N/A', Icons.trending_up, Colors.blue)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildCompetitiveCard('TOTAL IMPORT FROM EGYPT', analysis.totalExportsFromSelectedCountry ?? 'N/A', Icons.flag, Colors.green, rank: analysis.rank)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildCompetitiveCard('TOP COMPETITOR', analysis.competingCountryName ?? 'N/A', Icons.star, Colors.orange)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildCompetitiveCard('EXPORT OPPORTUNITY', analysis.competingCountryExports ?? 'N/A', Icons.insights, Colors.purple, subtitle: 'Potential market gap identified', rank: analysis.competingCountryRank != null ? int.tryParse(analysis.competingCountryRank!) : null)),
                      ],
                    );
                  },
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
        );
      },
    );
  }

  Widget _buildCompetitiveCard(String title, String value, IconData icon, Color color, {String? subtitle, int? rank}) {
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
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              if (rank != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '#$rank',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                  ),
                ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
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
              const Text('PESTLE Analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 800) {
                      return Column(
                        children: [
                          if (analysis.political != null) _buildPestleCard('Political', analysis.political!, 'Stable', Colors.green, 70, 'Govt. Stability Index'),
                          const SizedBox(height: 16),
                          if (analysis.economic != null) _buildPestleCard('Economic', analysis.economic!, 'Growing', Colors.blue, null, null, inflationRate: '2.4%', currencyTrend: 'Stable (EUR)'),
                          const SizedBox(height: 16),
                          if (analysis.social != null) _buildPestleCard('Social', analysis.social!, 'Evolving', Colors.grey, 80, 'Eco-Consciousness Score', scoreSegments: 5, filledSegments: 4),
                          const SizedBox(height: 16),
                          if (analysis.technological != null) _buildPestleCard('Technological', analysis.technological!, 'Advanced', Colors.purple, 80, 'Innovation Index'),
                          const SizedBox(height: 16),
                          if (analysis.legal != null) _buildPestleCard('Legal', analysis.legal!, 'Complex', Colors.red, 60, 'Compliance Difficulty', progressColor: Colors.orange),
                          const SizedBox(height: 16),
                          if (analysis.environmental != null) _buildPestleCard('Environmental', analysis.environmental!, 'Critical', Colors.green, 90, 'Sustainability Pressure'),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (analysis.political != null) Expanded(child: _buildPestleCard('Political', analysis.political!, 'Stable', Colors.green, 70, 'Govt. Stability Index')),
                            const SizedBox(width: 16),
                            if (analysis.economic != null) Expanded(child: _buildPestleCard('Economic', analysis.economic!, 'Growing', Colors.blue, null, null, inflationRate: '2.4%', currencyTrend: 'Stable (EUR)')),
                            const SizedBox(width: 16),
                            if (analysis.social != null) Expanded(child: _buildPestleCard('Social', analysis.social!, 'Evolving', Colors.grey, 80, 'Eco-Consciousness Score', scoreSegments: 5, filledSegments: 4)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (analysis.technological != null) Expanded(child: _buildPestleCard('Technological', analysis.technological!, 'Advanced', Colors.purple, 80, 'Innovation Index')),
                            const SizedBox(width: 16),
                            if (analysis.legal != null) Expanded(child: _buildPestleCard('Legal', analysis.legal!, 'Complex', Colors.red, 60, 'Compliance Difficulty', progressColor: Colors.orange)),
                            const SizedBox(width: 16),
                            if (analysis.environmental != null) Expanded(child: _buildPestleCard('Environmental', analysis.environmental!, 'Critical', Colors.green, 90, 'Sustainability Pressure')),
                          ],
                        ),
                      ],
                    );
                  },
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
        );
      },
    );
  }

  Widget _buildPestleCard(
    String title,
    String content,
    String status,
    Color statusColor,
    int? progressValue,
    String? progressLabel, {
    String? inflationRate,
    String? currencyTrend,
    int? scoreSegments,
    int? filledSegments,
    Color? progressColor,
  }) {
    // Parse content to extract positive and negative points
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final positivePoints = <String>[];
    final negativePoints = <String>[];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.toLowerCase().contains('potential') || 
          trimmed.toLowerCase().contains('risk') ||
          trimmed.toLowerCase().contains('vulnerability') ||
          trimmed.toLowerCase().contains('strict') ||
          trimmed.toLowerCase().contains('rigorous') ||
          trimmed.toLowerCase().contains('scrutiny')) {
        negativePoints.add(trimmed);
      } else {
        positivePoints.add(trimmed);
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Status Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Content Points
          ...positivePoints.take(3).map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          )),
          ...negativePoints.take(2).map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          )),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          
          // Bottom Metrics
          if (inflationRate != null && currencyTrend != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inflation Rate $inflationRate',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Currency Trend $currencyTrend',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            )
          else if (scoreSegments != null && filledSegments != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  progressLabel ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(scoreSegments, (index) {
                    return Expanded(
                      child: Container(
                        height: 6,
                        margin: EdgeInsets.only(right: index < scoreSegments - 1 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: index < filledSegments
                              ? Colors.green
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            )
          else if (progressValue != null && progressLabel != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  progressLabel,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressValue / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progressColor ?? statusColor,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
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
              const Text('SWOT Analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 800) {
                      return Column(
                        children: [
                          if (analysis.strengths != null) _buildSwotCard('Strengths', analysis.strengths!, Colors.green, Icons.trending_up),
                          const SizedBox(height: 16),
                          if (analysis.weaknesses != null) _buildSwotCard('Weaknesses', analysis.weaknesses!, Colors.red, Icons.trending_down),
                          const SizedBox(height: 16),
                          if (analysis.opportunities != null) _buildSwotCard('Opportunities', analysis.opportunities!, Colors.blue, Icons.lightbulb),
                          const SizedBox(height: 16),
                          if (analysis.threats != null) _buildSwotCard('Threats', analysis.threats!, Colors.orange, Icons.warning),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (analysis.strengths != null) Expanded(child: _buildSwotCard('Strengths', analysis.strengths!, Colors.green, Icons.trending_up)),
                            const SizedBox(width: 16),
                            if (analysis.weaknesses != null) Expanded(child: _buildSwotCard('Weaknesses', analysis.weaknesses!, Colors.red, Icons.trending_down)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (analysis.opportunities != null) Expanded(child: _buildSwotCard('Opportunities', analysis.opportunities!, Colors.blue, Icons.lightbulb)),
                            const SizedBox(width: 16),
                            if (analysis.threats != null) Expanded(child: _buildSwotCard('Threats', analysis.threats!, Colors.orange, Icons.warning)),
                          ],
                        ),
                      ],
                    );
                  },
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
        );
      },
    );
  }

  Widget _buildSwotCard(String title, String content, Color color, IconData icon) {
    // Parse content to extract points
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Content Points
          ...lines.take(5).map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.circle, color: color, size: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    point.trim(),
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }


  int _getBalance(BuildContext context) {
    return di.sl<AuthCubit>().state.user?.points ?? 0;
  }


  Widget _buildMarketPlanTab(BuildContext context, dynamic exploration) {
    final marketPlan = exploration.marketPlan;
    if (marketPlan == null) {
      return const Center(child: Text('No market plan available'));
    }

    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      bloc: di.sl<SubscriptionCubit>(),
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Market Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              BlurredContentWidget(
                isUnlocked: marketPlan.isSeen,
                unlockCost: marketPlan.unlockCost,
                currentBalance: _getBalance(context),
                onUnlock: marketPlan.isSeen
                    ? null
                    : () {
                        if (marketPlan.id != null) {
                          di.sl<SubscriptionCubit>().unlock(contentType: ContentType.marketPlan, targetId: marketPlan.id!);
                        }
                      },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 800) {
                      return Column(
                        children: [
                          if (marketPlan.productText != null) _buildMarketPlanCard('Product', marketPlan.productText!, Colors.blue, Icons.inventory_2),
                          const SizedBox(height: 16),
                          if (marketPlan.priceText != null) _buildMarketPlanCard('Price', marketPlan.priceText!, Colors.green, Icons.attach_money),
                          const SizedBox(height: 16),
                          if (marketPlan.placeText != null) _buildMarketPlanCard('Place', marketPlan.placeText!, Colors.orange, Icons.location_on),
                          const SizedBox(height: 16),
                          if (marketPlan.promotionText != null) _buildMarketPlanCard('Promotion', marketPlan.promotionText!, Colors.purple, Icons.campaign),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (marketPlan.productText != null) Expanded(child: _buildMarketPlanCard('Product', marketPlan.productText!, Colors.blue, Icons.inventory_2)),
                            const SizedBox(width: 16),
                            if (marketPlan.priceText != null) Expanded(child: _buildMarketPlanCard('Price', marketPlan.priceText!, Colors.green, Icons.attach_money)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (marketPlan.placeText != null) Expanded(child: _buildMarketPlanCard('Place', marketPlan.placeText!, Colors.orange, Icons.location_on)),
                            const SizedBox(width: 16),
                            if (marketPlan.promotionText != null) Expanded(child: _buildMarketPlanCard('Promotion', marketPlan.promotionText!, Colors.purple, Icons.campaign)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (!marketPlan.isSeen)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: UnlockButton(
                    cost: marketPlan.unlockCost,
                    currentBalance: _getBalance(context),
                    onUnlock: () {
                      if (marketPlan.id != null) {
                        di.sl<SubscriptionCubit>().unlock(contentType: ContentType.marketPlan, targetId: marketPlan.id!);
                      }
                    },
                    isLoading: state.isUnlocking,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMarketPlanCard(String title, String content, Color color, IconData icon) {
    // Parse content to extract points
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Content Points
          if (lines.length > 1)
            ...lines.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, color: color, size: 8),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point.trim(),
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ))
          else
            Text(
              content,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
        ],
      ),
    );
  }
}

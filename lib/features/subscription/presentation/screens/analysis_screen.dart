import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/theme.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/typing_text_widget.dart';
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
            return Center(child: Text('no_analysis_data_available'.tr()));
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
                    tooltip: 'back'.tr(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Image.asset('assets/logo 1.png', width: 40, height: 40, fit: BoxFit.contain),
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
                              '${user?.points ?? 0} ${'points'.tr()}',
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
                        tooltip: 'notifications'.tr(),
                      ),
                      // Profile
                      GestureDetector(
                        onTap: () {
                          // Handle profile
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
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
            _buildTab(context, 'overview_competitive_analysis'.tr(), AnalysisTab.competitiveAnalysis, exploration.competitiveAnalysis != null),
            const SizedBox(width: 8),
            _buildTab(context, 'pestle_analysis'.tr(), AnalysisTab.pestleAnalysis, exploration.pestleAnalysis != null),
            const SizedBox(width: 8),
            _buildTab(context, 'swot_analysis'.tr(), AnalysisTab.swotAnalysis, exploration.swotAnalysis != null),
            const SizedBox(width: 8),
            _buildTab(context, 'market_plan'.tr(), AnalysisTab.marketPlan, exploration.marketPlan != null),
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
      return Center(child: Text('no_competitive_analysis_available'.tr()));
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
              Text('competitive_analysis'.tr(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
                    final cards = [
                      {'title': 'total_imports'.tr().toUpperCase(), 'value': analysis.totalImports ?? 'N/A', 'icon': Icons.trending_up, 'color': Colors.blue},
                      {'title': 'total_import_from_egypt'.tr().toUpperCase(), 'value': analysis.totalExportsFromSelectedCountry ?? 'N/A', 'icon': Icons.flag, 'color': Colors.green, 'rank': analysis.rank},
                      {'title': 'top_competitor'.tr().toUpperCase(), 'value': analysis.competingCountryName ?? 'N/A', 'icon': Icons.star, 'color': Colors.orange},
                      {'title': 'export_opportunity'.tr().toUpperCase(), 'value': analysis.competingCountryExports ?? 'N/A', 'icon': Icons.insights, 'color': Colors.purple, 'subtitle': 'potential_market_gap'.tr(), 'rank': analysis.competingCountryRank != null ? int.tryParse(analysis.competingCountryRank!) : null},
                    ];
                    
                    if (constraints.maxWidth < 800) {
                      return Column(
                        children: cards.asMap().entries.map((entry) {
                          final index = entry.key;
                          final card = entry.value;
                          // Calculate delay: sum of all previous card values * typing speed
                          final previousLength = cards
                              .take(index)
                              .fold<int>(0, (sum, c) => sum + (c['value'] as String).length);
                          final delay = Duration(milliseconds: previousLength * 8);
                          return Padding(
                            padding: EdgeInsets.only(bottom: index < cards.length - 1 ? 16 : 0),
                            child: _buildCompetitiveCard(
                              card['title'] as String,
                              card['value'] as String,
                              card['icon'] as IconData,
                              card['color'] as Color,
                              subtitle: card['subtitle'] as String?,
                              rank: card['rank'] as int?,
                              delay: delay,
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return Row(
                      children: cards.asMap().entries.map((entry) {
                        final index = entry.key;
                        final card = entry.value;
                        // Calculate delay: sum of all previous card values * typing speed
                        final previousLength = cards
                            .take(index)
                            .fold<int>(0, (sum, c) => sum + (c['value'] as String).length);
                        final delay = Duration(milliseconds: previousLength * 8);
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: index < cards.length - 1 ? 16 : 0),
                            child: _buildCompetitiveCard(
                              card['title'] as String,
                              card['value'] as String,
                              card['icon'] as IconData,
                              card['color'] as Color,
                              subtitle: card['subtitle'] as String?,
                              rank: card['rank'] as int?,
                              delay: delay,
                            ),
                          ),
                        );
                      }).toList(),
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

  Widget _buildCompetitiveCard(String title, String value, IconData icon, Color color, {String? subtitle, int? rank, Duration delay = Duration.zero}) {
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TypingTextWidget(
                  text: value,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.4),
                  delay: delay,
                ),
              ),
              if (rank != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    '#$rank',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                  ),
                ),
            ],
          ),
          if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600]))],
        ],
      ),
    );
  }

  Widget _buildPESTLEAnalysisTab(BuildContext context, dynamic exploration) {
    final analysis = exploration.pestleAnalysis;
    if (analysis == null) {
      return Center(child: Text('no_pestle_analysis'.tr()));
    }

    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      bloc: di.sl<SubscriptionCubit>(),
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('pestle_analysis'.tr(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
                    // Build list of all PESTLE cards in order: P, E, S, T, L, E
                    final pestleCards = <Map<String, dynamic>>[];
                    if (analysis.political != null) {
                      pestleCards.add({
                        'title': 'political'.tr(),
                        'content': analysis.political!,
                        'status': 'stable'.tr(),
                        'color': Colors.green,
                        'progressValue': 70,
                        'progressLabel': 'govt_stability_index'.tr(),
                      });
                    }
                    if (analysis.economic != null) {
                      pestleCards.add({
                        'title': 'economic'.tr(),
                        'content': analysis.economic!,
                        'status': 'growing'.tr(),
                        'color': Colors.blue,
                        'inflationRate': '2.4%',
                        'currencyTrend': 'stable_eur'.tr(),
                      });
                    }
                    if (analysis.social != null) {
                      pestleCards.add({
                        'title': 'social'.tr(),
                        'content': analysis.social!,
                        'status': 'evolving'.tr(),
                        'color': Colors.grey,
                        'progressValue': 80,
                        'progressLabel': 'eco_consciousness_score'.tr(),
                        'scoreSegments': 5,
                        'filledSegments': 4,
                      });
                    }
                    if (analysis.technological != null) {
                      pestleCards.add({
                        'title': 'technological'.tr(),
                        'content': analysis.technological!,
                        'status': 'advanced'.tr(),
                        'color': Colors.purple,
                        'progressValue': 80,
                        'progressLabel': 'innovation_index'.tr(),
                      });
                    }
                    if (analysis.legal != null) {
                      pestleCards.add({
                        'title': 'legal'.tr(),
                        'content': analysis.legal!,
                        'status': 'complex'.tr(),
                        'color': Colors.red,
                        'progressValue': 60,
                        'progressLabel': 'compliance_difficulty'.tr(),
                        'progressColor': Colors.orange,
                      });
                    }
                    if (analysis.environmental != null) {
                      pestleCards.add({
                        'title': 'environmental'.tr(),
                        'content': analysis.environmental!,
                        'status': 'critical'.tr(),
                        'color': Colors.green,
                        'progressValue': 90,
                        'progressLabel': 'sustainability_pressure'.tr(),
                      });
                    }

                    // Calculate cumulative delays for each card
                    int cumulativeLength = 0;
                    final cardsWithDelays = <Map<String, dynamic>>[];
                    for (var card in pestleCards) {
                      final cardDelay = Duration(milliseconds: cumulativeLength * 8);
                      // Calculate total content length for this card (positive + negative points)
                      final content = card['content'] as String;
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
                      final cardContentLength = positivePoints.take(3).fold<int>(0, (sum, p) => sum + p.length) +
                          negativePoints.take(2).fold<int>(0, (sum, p) => sum + p.length);
                      cardsWithDelays.add({...card, 'delay': cardDelay});
                      cumulativeLength += cardContentLength;
                    }

                    if (constraints.maxWidth < 800) {
                      return Column(
                        children: cardsWithDelays.asMap().entries.map((entry) {
                          final index = entry.key;
                          final card = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(bottom: index < cardsWithDelays.length - 1 ? 16 : 0),
                            child: _buildPestleCard(
                              card['title'] as String,
                              card['content'] as String,
                              card['status'] as String,
                              card['color'] as Color,
                              card['progressValue'] as int?,
                              card['progressLabel'] as String?,
                              inflationRate: card['inflationRate'] as String?,
                              currencyTrend: card['currencyTrend'] as String?,
                              scoreSegments: card['scoreSegments'] as int?,
                              filledSegments: card['filledSegments'] as int?,
                              progressColor: card['progressColor'] as Color?,
                              cardDelay: card['delay'] as Duration,
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: cardsWithDelays.take(3).toList().asMap().entries.map((entry) {
                            final index = entry.key;
                            final card = entry.value;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: index < 2 ? 16 : 0),
                                child: _buildPestleCard(
                                  card['title'] as String,
                                  card['content'] as String,
                                  card['status'] as String,
                                  card['color'] as Color,
                                  card['progressValue'] as int?,
                                  card['progressLabel'] as String?,
                                  inflationRate: card['inflationRate'] as String?,
                                  currencyTrend: card['currencyTrend'] as String?,
                                  scoreSegments: card['scoreSegments'] as int?,
                                  filledSegments: card['filledSegments'] as int?,
                                  progressColor: card['progressColor'] as Color?,
                                  cardDelay: card['delay'] as Duration,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (cardsWithDelays.length > 3) ...[
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: cardsWithDelays.skip(3).toList().asMap().entries.map((entry) {
                              final index = entry.key;
                              final card = entry.value;
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: index < cardsWithDelays.length - 4 ? 16 : 0),
                                  child: _buildPestleCard(
                                    card['title'] as String,
                                    card['content'] as String,
                                    card['status'] as String,
                                    card['color'] as Color,
                                    card['progressValue'] as int?,
                                    card['progressLabel'] as String?,
                                    inflationRate: card['inflationRate'] as String?,
                                    currencyTrend: card['currencyTrend'] as String?,
                                    scoreSegments: card['scoreSegments'] as int?,
                                    filledSegments: card['filledSegments'] as int?,
                                    progressColor: card['progressColor'] as Color?,
                                    cardDelay: card['delay'] as Duration,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
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
    Duration cardDelay = Duration.zero,
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Status Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content Points
          ...positivePoints
              .take(3)
              .toList()
              .asMap()
              .entries
              .map(
                (entry) {
                  final index = entry.key;
                  final point = entry.value;
                  // Calculate delay: card delay + sum of all previous text lengths in this card * typing speed
                  final previousLength = positivePoints
                      .take(index)
                      .fold<int>(0, (sum, p) => sum + p.length);
                  final delay = Duration(milliseconds: cardDelay.inMilliseconds + (previousLength * 8));
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TypingTextWidget(
                            text: point,
                            style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.6),
                            delay: delay,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ...negativePoints
              .take(2)
              .toList()
              .asMap()
              .entries
              .map(
                (entry) {
                  final index = entry.key;
                  final point = entry.value;
                  // Calculate delay: card delay + previous positive points + previous negative points
                  final positiveLength = positivePoints.take(3).fold<int>(0, (sum, p) => sum + p.length);
                  final previousNegativeLength = negativePoints
                      .take(index)
                      .fold<int>(0, (sum, p) => sum + p.length);
                  final delay = Duration(milliseconds: cardDelay.inMilliseconds + ((positiveLength + previousNegativeLength) * 8));
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TypingTextWidget(
                            text: point,
                            style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.6),
                            delay: delay,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Bottom Metrics
          if (inflationRate != null && currencyTrend != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('inflation_rate_label'.tr(namedArgs: {'rate': inflationRate}), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text('currency_trend_label'.tr(namedArgs: {'trend': currencyTrend}), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            )
          else if (scoreSegments != null && filledSegments != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(progressLabel ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(scoreSegments, (index) {
                    return Expanded(
                      child: Container(
                        height: 6,
                        margin: EdgeInsets.only(right: index < scoreSegments - 1 ? 4 : 0),
                        decoration: BoxDecoration(color: index < filledSegments ? Colors.green : Colors.grey[300], borderRadius: BorderRadius.circular(3)),
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
                Text(progressLabel, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressValue / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor ?? statusColor),
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
      return Center(child: Text('no_swot_analysis_available'.tr()));
    }

    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      bloc: di.sl<SubscriptionCubit>(),
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('swot_analysis'.tr(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
                    // Build list of all SWOT cards in order: Strengths, Weaknesses, Opportunities, Threats
                    final swotCards = <Map<String, dynamic>>[];
                    if (analysis.strengths != null) {
                      swotCards.add({
                        'title': 'strengths'.tr(),
                        'content': analysis.strengths!,
                        'color': Colors.green,
                        'icon': Icons.trending_up,
                      });
                    }
                    if (analysis.weaknesses != null) {
                      swotCards.add({
                        'title': 'weaknesses'.tr(),
                        'content': analysis.weaknesses!,
                        'color': Colors.red,
                        'icon': Icons.trending_down,
                      });
                    }
                    if (analysis.opportunities != null) {
                      swotCards.add({
                        'title': 'opportunities'.tr(),
                        'content': analysis.opportunities!,
                        'color': Colors.blue,
                        'icon': Icons.lightbulb,
                      });
                    }
                    if (analysis.threats != null) {
                      swotCards.add({
                        'title': 'threats'.tr(),
                        'content': analysis.threats!,
                        'color': Colors.orange,
                        'icon': Icons.warning,
                      });
                    }

                    // Calculate cumulative delays for each card
                    int cumulativeLength = 0;
                    final cardsWithDelays = <Map<String, dynamic>>[];
                    for (var card in swotCards) {
                      final cardDelay = Duration(milliseconds: cumulativeLength * 8);
                      // Calculate total content length for this card
                      final content = card['content'] as String;
                      final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
                      final cardContentLength = lines.take(5).fold<int>(0, (sum, p) => sum + p.trim().length);
                      cardsWithDelays.add({...card, 'delay': cardDelay});
                      cumulativeLength += cardContentLength;
                    }

                    if (constraints.maxWidth < 800) {
                      return Column(
                        children: cardsWithDelays.asMap().entries.map((entry) {
                          final index = entry.key;
                          final card = entry.value;
                          return Padding(
                            key: ValueKey('swot_${card['title']}_$index'),
                            padding: EdgeInsets.only(bottom: index < cardsWithDelays.length - 1 ? 16 : 0),
                            child: _buildSwotCard(
                              card['title'] as String,
                              card['content'] as String,
                              card['color'] as Color,
                              card['icon'] as IconData,
                              cardDelay: card['delay'] as Duration,
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: cardsWithDelays.take(2).toList().asMap().entries.map((entry) {
                            final index = entry.key;
                            final card = entry.value;
                            return Expanded(
                              key: ValueKey('swot_${card['title']}_$index'),
                              child: Padding(
                                padding: EdgeInsets.only(right: index < 1 ? 16 : 0),
                                child: _buildSwotCard(
                                  card['title'] as String,
                                  card['content'] as String,
                                  card['color'] as Color,
                                  card['icon'] as IconData,
                                  cardDelay: card['delay'] as Duration,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (cardsWithDelays.length > 2) ...[
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: cardsWithDelays.skip(2).toList().asMap().entries.map((entry) {
                              final index = entry.key;
                              final card = entry.value;
                              return Expanded(
                                key: ValueKey('swot_${card['title']}_${index + 2}'),
                                child: Padding(
                                  padding: EdgeInsets.only(right: index < cardsWithDelays.length - 3 ? 16 : 0),
                                  child: _buildSwotCard(
                                    card['title'] as String,
                                    card['content'] as String,
                                    card['color'] as Color,
                                    card['icon'] as IconData,
                                    cardDelay: card['delay'] as Duration,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
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

  Widget _buildSwotCard(String title, String content, Color color, IconData icon, {Duration cardDelay = Duration.zero}) {
    // Parse content to extract points
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content Points
          ...lines
              .take(5)
              .toList()
              .asMap()
              .entries
              .map(
                (entry) {
                  final index = entry.key;
                  final point = entry.value;
                  // Calculate delay: card delay + sum of all previous text lengths in this card * typing speed
                  final previousLength = lines
                      .take(index)
                      .fold<int>(0, (sum, p) => sum + p.trim().length);
                  final delay = Duration(milliseconds: cardDelay.inMilliseconds + (previousLength * 8));
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, color: color, size: 8),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TypingTextWidget(
                            text: point.trim(),
                            style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.6),
                            delay: delay,
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

  int _getBalance(BuildContext context) {
    return di.sl<AuthCubit>().state.user?.points ?? 0;
  }

  Widget _buildMarketPlanTab(BuildContext context, dynamic exploration) {
    final marketPlan = exploration.marketPlan;
    if (marketPlan == null) {
      return Center(child: Text('no_market_plan'.tr()));
    }

    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      bloc: di.sl<SubscriptionCubit>(),
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('market_plan'.tr(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
                    // Build list of all Market Plan cards in order: Product, Price, Place, Promotion
                    final marketPlanCards = <Map<String, dynamic>>[];
                    if (marketPlan.productText != null) {
                      marketPlanCards.add({
                        'title': 'product_label'.tr(),
                        'content': marketPlan.productText!,
                        'color': Colors.blue,
                        'icon': Icons.inventory_2,
                      });
                    }
                    if (marketPlan.priceText != null) {
                      marketPlanCards.add({
                        'title': 'price'.tr(),
                        'content': marketPlan.priceText!,
                        'color': Colors.green,
                        'icon': Icons.attach_money,
                      });
                    }
                    if (marketPlan.placeText != null) {
                      marketPlanCards.add({
                        'title': 'place'.tr(),
                        'content': marketPlan.placeText!,
                        'color': Colors.orange,
                        'icon': Icons.location_on,
                      });
                    }
                    if (marketPlan.promotionText != null) {
                      marketPlanCards.add({
                        'title': 'promotion'.tr(),
                        'content': marketPlan.promotionText!,
                        'color': Colors.purple,
                        'icon': Icons.campaign,
                      });
                    }

                    // Calculate cumulative delays for each card
                    int cumulativeLength = 0;
                    final cardsWithDelays = <Map<String, dynamic>>[];
                    for (var card in marketPlanCards) {
                      final cardDelay = Duration(milliseconds: cumulativeLength * 8);
                      // Calculate total content length for this card
                      final content = card['content'] as String;
                      final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
                      final cardContentLength = lines.length > 1
                          ? lines.fold<int>(0, (sum, p) => sum + p.trim().length)
                          : content.length;
                      cardsWithDelays.add({...card, 'delay': cardDelay});
                      cumulativeLength += cardContentLength;
                    }

                    if (constraints.maxWidth < 800) {
                      return Column(
                        children: cardsWithDelays.asMap().entries.map((entry) {
                          final index = entry.key;
                          final card = entry.value;
                          return Padding(
                            key: ValueKey('market_${card['title']}_$index'),
                            padding: EdgeInsets.only(bottom: index < cardsWithDelays.length - 1 ? 16 : 0),
                            child: _buildMarketPlanCard(
                              card['title'] as String,
                              card['content'] as String,
                              card['color'] as Color,
                              card['icon'] as IconData,
                              cardDelay: card['delay'] as Duration,
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: cardsWithDelays.take(2).toList().asMap().entries.map((entry) {
                            final index = entry.key;
                            final card = entry.value;
                            return Expanded(
                              key: ValueKey('market_${card['title']}_$index'),
                              child: Padding(
                                padding: EdgeInsets.only(right: index < 1 ? 16 : 0),
                                child: _buildMarketPlanCard(
                                  card['title'] as String,
                                  card['content'] as String,
                                  card['color'] as Color,
                                  card['icon'] as IconData,
                                  cardDelay: card['delay'] as Duration,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (cardsWithDelays.length > 2) ...[
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: cardsWithDelays.skip(2).toList().asMap().entries.map((entry) {
                              final index = entry.key;
                              final card = entry.value;
                              return Expanded(
                                key: ValueKey('market_${card['title']}_${index + 2}'),
                                child: Padding(
                                  padding: EdgeInsets.only(right: index < cardsWithDelays.length - 3 ? 16 : 0),
                                  child: _buildMarketPlanCard(
                                    card['title'] as String,
                                    card['content'] as String,
                                    card['color'] as Color,
                                    card['icon'] as IconData,
                                    cardDelay: card['delay'] as Duration,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
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

  Widget _buildMarketPlanCard(String title, String content, Color color, IconData icon, {Duration cardDelay = Duration.zero}) {
    // Parse content to extract points
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content Points
          if (lines.length > 1)
            ...lines.toList().asMap().entries.map(
              (entry) {
                final index = entry.key;
                final point = entry.value;
                // Calculate delay: card delay + sum of all previous text lengths in this card * typing speed
                final previousLength = lines
                    .take(index)
                    .fold<int>(0, (sum, p) => sum + p.trim().length);
                final delay = Duration(milliseconds: cardDelay.inMilliseconds + (previousLength * 8));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, color: color, size: 8),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TypingTextWidget(
                          text: point.trim(),
                          style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.6),
                          delay: delay,
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            TypingTextWidget(
              text: content,
              style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.6),
              delay: cardDelay,
            ),
        ],
      ),
    );
  }
}

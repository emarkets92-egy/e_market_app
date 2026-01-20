import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../../../../config/theme.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../widgets/blurred_content_widget.dart';
import '../widgets/shipment_record_card.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../data/models/unlock_item_model.dart';
import '../../data/models/profile_model.dart';
import '../../../../shared/widgets/app_error_widget.dart';

class ProfileDetailScreen extends StatefulWidget {
  final String profileId;

  const ProfileDetailScreen({super.key, required this.profileId});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  bool _showSeenRecords = false; // Toggle for shipment records filter
  bool _isImportHistoryExpanded = false; // Toggle for import history visibility
  bool _isTableView = true; // true = table, false = card

  @override
  void initState() {
    super.initState();
    // Fetch shipment records when screen initializes
    di.sl<SubscriptionCubit>().getShipmentRecords(profileId: widget.profileId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        bloc: di.sl<SubscriptionCubit>(),
        listener: (context, state) {
          // Show error messages via snackbar
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
          }
          // Show success messages via snackbar
          if (state.successMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.successMessage!), backgroundColor: Colors.green, duration: const Duration(seconds: 2)));
            // Clear the success message after showing
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                di.sl<SubscriptionCubit>().clearSuccessMessage();
              } catch (e) {
                // Ignore errors if cubit is disposed
              }
            });
          }
        },
        builder: (context, state) {
          // Find profile in either list
          final allProfiles = [...state.unseenProfiles, ...state.seenProfiles];

          // If not found in lists (e.g. direct deep link), we might need to fetch it separately
          // For now, fallback or show loading/error if not found
          if (allProfiles.isEmpty && !state.isLoading) {
            // Try to find in the current state anyway or show error
            return Center(child: Text('profile_not_found'.tr()));
          }

          final profile = allProfiles.firstWhere(
            (p) => p.id == widget.profileId,
            orElse: () => allProfiles.first, // Fallback logic
          );

          return Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBreadcrumb(context, profile),
                        const SizedBox(height: 16),
                        _buildProfileHeader(context, profile),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 300, child: _buildLeftSidebar(context, profile)),
                            const SizedBox(width: 24),
                            Expanded(child: _buildMainContent(context, profile, state)),
                          ],
                        ),
                        const SizedBox(height: 48),
                        _buildFooter(),
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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => context.pop(),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 16),
              InkWell(onTap: () => context.go(RouteNames.home), child: Image.asset('assets/logo 1.png', width: 40, height: 40)),
            ],
          ),
          BlocBuilder<AuthCubit, AuthState>(
            bloc: di.sl<AuthCubit>(),
            builder: (context, authState) {
              final userName = authState.user?.name ?? 'User';
              return Row(
                children: [
                  Text(userName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryBlue,
                    child: Text(
                      userName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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

  Widget _buildBreadcrumb(BuildContext context, ProfileModel profile) {
    final name = _getProfileName(profile);
    return Row(
      children: [
        InkWell(
          onTap: () => context.go(RouteNames.home),
          child: const Icon(Icons.home, size: 16, color: AppTheme.primaryBlue),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => context.go(RouteNames.home),
          child: Text('home'.tr(), style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 14)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('/', style: TextStyle(color: Colors.grey)),
        ),
        Text('importers_directory'.tr(), style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 14)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('/', style: TextStyle(color: Colors.grey)),
        ),
        Text(
          name,
          style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileModel profile) {
    final name = _getProfileName(profile);
    final address = profile.address ?? 'N/A';
    final countryName = profile.countryName;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Center(
                    child: Text(
                      name.length >= 2 ? name.substring(0, 2).toUpperCase() : (name.isNotEmpty ? (name[0] + name[0]).toUpperCase() : 'IM'),
                      style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (countryName != null && countryName.isNotEmpty) ...[
                          const Icon(Icons.flag, size: 16, color: Colors.red),
                          const SizedBox(width: 6),
                          Text(countryName, style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B))),
                          if (address != 'N/A') ...[const SizedBox(width: 8), const Text('•', style: TextStyle(color: Colors.grey)), const SizedBox(width: 8)],
                        ],
                        if (address != 'N/A') ...[
                          const Icon(Icons.location_on, size: 16, color: AppTheme.primaryBlue),
                          const SizedBox(width: 6),
                          Text(address, style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B))),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Send Message Button
        if (profile.isSeen)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                context.push(RouteNames.chatWithRecipient(profile.id));
              },
              icon: const Icon(Icons.message),
              label: Text('send_message'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLeftSidebar(BuildContext context, ProfileModel profile) {
    final balance = _getCurrentBalance(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'contact_information'.tr(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              // Edit icon removed
            ],
          ),
          const SizedBox(height: 24),
          BlurredContentWidget(
            isUnlocked: profile.isSeen,
            unlockCost: profile.unlockCost,
            currentBalance: balance,
            onUnlock: () => _unlockProfile(context, profile.id),
            child: Column(
              children: [
                _buildSidebarItem(
                  icon: Icons.email,
                  label: 'email_address'.tr().toUpperCase(),
                  value: (profile.email != null && profile.email!.isNotEmpty) ? profile.email! : 'Soon',
                  onTap: () => _launchUrl(profile.email, scheme: 'mailto'),
                ),
                const SizedBox(height: 20),
                if (profile.whatsapp != null) ...[
                  _buildSidebarItem(
                    icon: Icons.chat,
                    label: 'whatsapp'.tr().toUpperCase(),
                    value: profile.whatsapp!,
                    onTap: () => _launchUrl(profile.whatsapp, scheme: 'https'), // Or whatsapp scheme
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 24.0), child: Divider(height: 1)),

          Center(
            child: InkWell(
              onTap: (profile.website != null && profile.website!.isNotEmpty && profile.isSeen) ? () => _launchUrl(profile.website) : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'view_company_website'.tr(),
                    style: TextStyle(color: (profile.isSeen && profile.website != null && profile.website!.isNotEmpty) ? AppTheme.primaryBlue : Colors.grey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: (profile.isSeen && profile.website != null && profile.website!.isNotEmpty) ? AppTheme.primaryBlue : Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({required IconData icon, required String label, required String value, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: AppTheme.primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[500], letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ProfileModel profile, SubscriptionState state) {
    return Column(
      children: [
        // Stats Row - Hidden for now, will be restored when API provides the data
        // Row(
        //   children: [
        //     Expanded(
        //       child: _buildStatCard(label: 'TOTAL IMPORTS', value: '1,245', subValue: '+12% this year', subValueColor: Colors.green, isTrend: true),
        //     ),
        //     const SizedBox(width: 16),
        //     Expanded(
        //       child: _buildStatCard(label: 'TOP ORIGIN', value: 'China', showFlag: true),
        //     ),
        //     const SizedBox(width: 16),
        //     Expanded(
        //       child: _buildStatCard(label: 'AVG. VOLUME', value: '\$45k', subValue: 'Per shipment'),
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 24),

        // Import History Table
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('import_history'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('recent_shipments_description'.tr(), style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                    ],
                  ),
                  Row(
                    children: [
                      // Filter Toggle
                      Container(
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            _buildFilterButton('new_records'.tr(), !_showSeenRecords, () => setState(() => _showSeenRecords = false)),
                            _buildFilterButton('seen_records'.tr(), _showSeenRecords, () => setState(() => _showSeenRecords = true)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // View Toggle (table ↔ card)
                      Container(
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildViewToggleButton(icon: Icons.view_list, isSelected: _isTableView, onTap: () => setState(() => _isTableView = true)),
                            _buildViewToggleButton(icon: Icons.grid_view, isSelected: !_isTableView, onTap: () => setState(() => _isTableView = false)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Expand/Collapse Button
                      InkWell(
                        onTap: () => setState(() => _isImportHistoryExpanded = !_isImportHistoryExpanded),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                          child: Icon(_isImportHistoryExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_isImportHistoryExpanded) ...[
                const SizedBox(height: 24),
                if (state.isLoading && state.seenShipmentRecords.isEmpty && state.unseenShipmentRecords.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (state.error != null && state.seenShipmentRecords.isEmpty && state.unseenShipmentRecords.isEmpty)
                  AppErrorWidget(
                    message: state.error!,
                    onRetry: () {
                      di.sl<SubscriptionCubit>().getShipmentRecords(profileId: widget.profileId);
                    },
                  )
                else
                  _isTableView ? _buildHistoryTable(context, state) : _buildHistoryCards(context, state),
                const SizedBox(height: 24),
                if (state.error == null || state.seenShipmentRecords.isNotEmpty || state.unseenShipmentRecords.isNotEmpty) _buildTablePagination(state),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String text, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 13, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal, color: isActive ? Colors.black87 : Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildViewToggleButton({required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isSelected ? Colors.white : Colors.grey[600], size: 20),
      ),
    );
  }

  static String _formatRecordDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Widget _buildHistoryTable(BuildContext context, SubscriptionState state) {
    final records = _showSeenRecords ? state.seenShipmentRecords : state.unseenShipmentRecords;
    final showAction = !_showSeenRecords; // No action column for seen records

    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(_showSeenRecords ? 'no_seen_records_found'.tr() : 'no_new_records_available'.tr(), style: TextStyle(color: Colors.grey[500])),
        ),
      );
    }

    final columns = <DataColumn>[
      _buildDataColumn('exporter_name'.tr().toUpperCase()),
      _buildDataColumn('country_of_origin'.tr().toUpperCase()),
      _buildDataColumn('net_weight'.tr().toUpperCase()),
      _buildDataColumn('net_weight_unit'.tr().toUpperCase()),
      _buildDataColumn('port_of_arrival'.tr().toUpperCase()),
      _buildDataColumn('port_of_departure'.tr().toUpperCase()),
      _buildDataColumn('notify_party'.tr().toUpperCase()),
      _buildDataColumn('notify_address'.tr().toUpperCase()),
      _buildDataColumn('hs_code'.tr().toUpperCase()),
      _buildDataColumn('quantity'.tr().toUpperCase()),
      _buildDataColumn('value'.tr().toUpperCase()),
      _buildDataColumn('unlocked_at'.tr().toUpperCase()),
      _buildDataColumn('id'.tr().toUpperCase()),
      if (showAction) _buildDataColumn('action'.tr().toUpperCase()),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.transparent),
        dataRowColor: WidgetStateProperty.all(Colors.transparent),
        columnSpacing: 24,
        horizontalMargin: 0,
        columns: columns,
        rows: records.map((record) {
          final cells = <DataCell>[
            DataCell(SizedBox(width: 150, child: Text(record.exporterName ?? '', style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))),
            DataCell(Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.flag, size: 16, color: Colors.grey), const SizedBox(width: 8), Text(record.countryOfOrigin ?? '')])),
            DataCell(SizedBox(width: 100, child: Text(record.netWeight ?? '', overflow: TextOverflow.ellipsis))),
            DataCell(SizedBox(width: 80, child: Text(record.netWeightUnit ?? '', overflow: TextOverflow.ellipsis))),
            DataCell(SizedBox(width: 100, child: Text(record.portOfArrival ?? '', overflow: TextOverflow.ellipsis))),
            DataCell(SizedBox(width: 100, child: Text(record.portOfDeparture ?? '', overflow: TextOverflow.ellipsis))),
            DataCell(SizedBox(width: 120, child: Text(record.notifyParty ?? '', overflow: TextOverflow.ellipsis))),
            DataCell(SizedBox(width: 120, child: Text(record.notifyAddress ?? '', overflow: TextOverflow.ellipsis))),
            DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)), child: Text(record.hsCode ?? '', style: TextStyle(color: Colors.blue[800], fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))),
            DataCell(Text(record.quantity?.toString() ?? '')),
            DataCell(Text(record.value?.toString() ?? '')),
            DataCell(SizedBox(width: 100, child: Text(_formatRecordDate(record.unlockedAt), overflow: TextOverflow.ellipsis))),
            DataCell(SizedBox(width: 100, child: Text(record.id, overflow: TextOverflow.ellipsis))),
            if (showAction)
              DataCell(IconButton(icon: const Icon(Icons.lock_open, color: AppTheme.primaryBlue, size: 20), onPressed: () { di.sl<SubscriptionCubit>().unlock(contentType: ContentType.shipmentRecords, targetId: record.id); })),
          ];
          return DataRow(cells: cells);
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryCards(BuildContext context, SubscriptionState state) {
    final records = _showSeenRecords ? state.seenShipmentRecords : state.unseenShipmentRecords;

    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(_showSeenRecords ? 'no_seen_records_found'.tr() : 'no_new_records_available'.tr(), style: TextStyle(color: Colors.grey[500])),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1100 ? 3 : (screenWidth > 700 ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return ShipmentRecordCard(record: record, isLocked: !record.isSeen);
      },
    );
  }

  DataColumn _buildDataColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[500], letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildTablePagination(SubscriptionState state) {
    final currentPage = _showSeenRecords ? state.seenShipmentRecordsPage : state.unseenShipmentRecordsPage;
    final totalPages = _showSeenRecords ? state.seenShipmentRecordsTotalPages : state.unseenShipmentRecordsTotalPages;
    final totalRecords = _showSeenRecords ? state.seenShipmentRecordsTotal : state.unseenShipmentRecordsTotal;

    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'total_records'.tr(namedArgs: {'count': totalRecords.toString()}),
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: currentPage > 1 ? () => _loadPage(currentPage - 1) : null),
            Text('page_of'.tr(namedArgs: {'current': currentPage.toString(), 'total': totalPages.toString()})),
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: currentPage < totalPages ? () => _loadPage(currentPage + 1) : null),
          ],
        ),
      ],
    );
  }

  void _loadPage(int page) {
    if (_showSeenRecords) {
      di.sl<SubscriptionCubit>().getShipmentRecords(profileId: widget.profileId, seenPage: page);
    } else {
      di.sl<SubscriptionCubit>().getShipmentRecords(profileId: widget.profileId, unseenPage: page);
    }
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('copyright_full'.tr(), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            Row(
              children: [
                _buildFooterLink('privacy_policy'.tr()),
                const SizedBox(width: 24),
                _buildFooterLink('terms_of_service'.tr()),
                const SizedBox(width: 24),
                _buildFooterLink('report_user'.tr()),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return InkWell(
      onTap: () {},
      child: Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
    );
  }

  int _getCurrentBalance(BuildContext context) {
    try {
      return context.read<AuthCubit>().state.user?.points ?? 0;
    } catch (e) {
      return di.sl<AuthCubit>().state.user?.points ?? 0;
    }
  }

  String _getProfileName(ProfileModel profile) {
    if (profile.email != null && profile.email!.isNotEmpty) {
      final emailPrefix = profile.email!.split('@').first;
      if (emailPrefix.isNotEmpty) {
        final name = emailPrefix
            .replaceAll('.', ' ')
            .split(' ')
            .where((word) => word.isNotEmpty)
            .map((word) => word[0].toUpperCase() + (word.length > 1 ? word.substring(1) : ''))
            .join(' ');
        if (name.isNotEmpty) {
          return name;
        }
      }
    }
    // Fallback: use company name if available
    if (profile.companyName != null && profile.companyName!.isNotEmpty) {
      return profile.companyName!;
    }
    // Final fallback: use profile ID (safely handle short IDs)
    final idLength = profile.id.length;
    final idPrefix = idLength >= 8 ? profile.id.substring(0, 8) : profile.id;
    return 'Importer $idPrefix';
  }

  Future<void> _launchUrl(String? urlString, {String scheme = 'https'}) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri uri;
    if (scheme == 'mailto') {
      uri = Uri.parse('mailto:$urlString');
    } else if (scheme == 'tel') {
      uri = Uri.parse('tel:$urlString');
    } else {
      uri = urlString.startsWith('http') ? Uri.parse(urlString) : Uri.parse('https://$urlString');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: (scheme == 'mailto' || scheme == 'tel') ? LaunchMode.platformDefault : LaunchMode.externalApplication);
    }
  }

  void _unlockProfile(BuildContext context, String profileId) {
    di.sl<SubscriptionCubit>().unlock(contentType: ContentType.profileContact, targetId: profileId);
  }
}

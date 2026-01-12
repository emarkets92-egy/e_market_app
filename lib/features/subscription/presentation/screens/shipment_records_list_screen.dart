import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../../data/models/shipment_record_model.dart';
import '../../data/models/unlock_item_model.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../widgets/blurred_content_widget.dart';
import '../widgets/unlock_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class ShipmentRecordsListScreen extends StatefulWidget {
  final String profileId;

  const ShipmentRecordsListScreen({super.key, required this.profileId});

  @override
  State<ShipmentRecordsListScreen> createState() => _ShipmentRecordsListScreenState();
}

class _ShipmentRecordsListScreenState extends State<ShipmentRecordsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _lastShownSuccessMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load shipment records on init
    di.sl<SubscriptionCubit>().getShipmentRecords(profileId: widget.profileId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUnseenShipmentRecords(int page) {
    di.sl<SubscriptionCubit>().getShipmentRecords(profileId: widget.profileId, unseenPage: page);
  }

  void _loadSeenShipmentRecords(int page) {
    di.sl<SubscriptionCubit>().getShipmentRecords(profileId: widget.profileId, seenPage: page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('shipment_records'.tr()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
            bloc: di.sl<SubscriptionCubit>(),
            builder: (context, state) {
              return TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: '${'new_records'.tr()}${state.unseenShipmentRecordsTotal > 0 ? ' (${state.unseenShipmentRecordsTotal})' : ''}'),
                  Tab(text: '${'unlocked'.tr()}${state.seenShipmentRecordsTotal > 0 ? ' (${state.seenShipmentRecordsTotal})' : ''}'),
                ],
              );
            },
          ),
        ),
      ),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        bloc: di.sl<SubscriptionCubit>(),
        listener: (context, state) {
          // Only show snackbar if this is a new success message we haven't shown yet
          if (state.successMessage != null && state.successMessage != _lastShownSuccessMessage) {
            _lastShownSuccessMessage = state.successMessage;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.successMessage!), backgroundColor: Colors.green, duration: const Duration(seconds: 2)));
            // Clear the success message after showing using post-frame callback
            // to avoid triggering listener again immediately
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                di.sl<SubscriptionCubit>().clearSuccessMessage();
              } catch (e) {
                // Ignore errors if cubit is disposed
              }
            });
          }
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.unseenShipmentRecords.isEmpty && state.seenShipmentRecords.isEmpty) {
            return const LoadingIndicator();
          }

          if (state.error != null && state.unseenShipmentRecords.isEmpty && state.seenShipmentRecords.isEmpty) {
            return AppErrorWidget(
              message: state.error!,
              onRetry: () {
                di.sl<SubscriptionCubit>().getShipmentRecords(profileId: widget.profileId);
              },
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: New Records (Unseen)
              _buildShipmentRecordList(
                context: context,
                records: state.unseenShipmentRecords,
                isLoading: state.isLoading,
                currentPage: state.unseenShipmentRecordsPage,
                totalPages: state.unseenShipmentRecordsTotalPages,
                onPageChanged: _loadUnseenShipmentRecords,
                isUnlocking: state.isUnlocking,
                unlockCost: state.shipmentRecordsUnlockCost ?? 0,
              ),
              // Tab 2: Unlocked Records (Seen)
              _buildShipmentRecordList(
                context: context,
                records: state.seenShipmentRecords,
                isLoading: state.isLoading,
                currentPage: state.seenShipmentRecordsPage,
                totalPages: state.seenShipmentRecordsTotalPages,
                onPageChanged: _loadSeenShipmentRecords,
                isUnlocking: state.isUnlocking,
                unlockCost: state.shipmentRecordsUnlockCost ?? 0,
                isSeen: true,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShipmentRecordList({
    required BuildContext context,
    required List<ShipmentRecordModel> records,
    required bool isLoading,
    required int currentPage,
    required int totalPages,
    required Function(int) onPageChanged,
    required bool isUnlocking,
    required int unlockCost,
    bool isSeen = false,
  }) {
    if (records.isEmpty && !isLoading) {
      // Check if there are more pages before showing "No records found"
      // Only for new records (unseen), not for unlocked records
      if (!isSeen && totalPages > 1 && currentPage < totalPages) {
        // Load next page if available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onPageChanged(currentPage + 1);
        });
        return const Center(child: CircularProgressIndicator());
      }
      return Center(child: Text(isSeen ? 'no_unlocked_records_found'.tr() : 'no_new_records_found'.tr()));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return _buildShipmentRecordCard(
                context: context,
                record: record,
                isUnlocking: isUnlocking,
                unlockCost: unlockCost,
                onUnlock: isSeen
                    ? () {} // Dummy callback for seen records
                    : () {
                        di.sl<SubscriptionCubit>().unlock(contentType: ContentType.shipmentRecords, targetId: record.id);
                      },
              );
            },
          ),
        ),
        if (totalPages > 1) _buildPaginationControls(currentPage: currentPage, totalPages: totalPages, onPageChanged: onPageChanged),
      ],
    );
  }

  Widget _buildShipmentRecordCard({
    required BuildContext context,
    required ShipmentRecordModel record,
    required bool isUnlocking,
    required int unlockCost,
    required VoidCallback onUnlock,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_getMonthName(record.month)} ${record.year}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            BlurredContentWidget(
              isUnlocked: record.isSeen,
              unlockCost: unlockCost,
              currentBalance: _getCurrentBalance(context),
              onUnlock: record.isSeen ? null : onUnlock,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (record.exporterName != null) Text('${'exporter_name'.tr()}: ${record.exporterName}'),
                  if (record.countryOfOrigin != null) Text('${'country_of_origin'.tr()}: ${record.countryOfOrigin}'),
                  if (record.netWeight != null) Text('${'net_weight'.tr()}: ${record.netWeight} ${record.netWeightUnit ?? ''}'),
                  if (record.portOfArrival != null) Text('${'port_of_arrival'.tr()}: ${record.portOfArrival}'),
                  if (record.portOfDeparture != null) Text('${'port_of_departure'.tr()}: ${record.portOfDeparture}'),
                  if (record.notifyParty != null) Text('${'notify_party'.tr()}: ${record.notifyParty}'),
                  if (record.notifyAddress != null) Text('${'notify_address'.tr()}: ${record.notifyAddress}'),
                  if (record.hsCode != null) Text('${'hs_code'.tr()}: ${record.hsCode}'),
                  if (record.quantity != null) Text('${'quantity'.tr()}: ${record.quantity}'),
                  if (record.value != null) Text('${'value'.tr()}: ${record.value}'),
                ],
              ),
            ),
            if (!record.isSeen)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: UnlockButton(cost: unlockCost, currentBalance: _getCurrentBalance(context), onUnlock: onUnlock, isLoading: isUnlocking),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls({required int currentPage, required int totalPages, required Function(int) onPageChanged}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null),
          Text('page_of'.tr(namedArgs: {'current': currentPage.toString(), 'total': totalPages.toString()})),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null),
        ],
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

  String _getMonthName(int month) {
    final months = [
      'january'.tr(),
      'february'.tr(),
      'march'.tr(),
      'april'.tr(),
      'may'.tr(),
      'june'.tr(),
      'july'.tr(),
      'august'.tr(),
      'september'.tr(),
      'october'.tr(),
      'november'.tr(),
      'december'.tr()
    ];
    return months[month - 1];
  }
}

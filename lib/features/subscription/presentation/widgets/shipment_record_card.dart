import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/theme.dart';
import '../../data/models/shipment_record_model.dart';
import '../../data/models/unlock_item_model.dart';
import '../cubit/subscription_cubit.dart';
import '../../../../core/di/injection_container.dart' as di;

class ShipmentRecordCard extends StatefulWidget {
  final ShipmentRecordModel record;
  final bool isLocked;

  const ShipmentRecordCard({super.key, required this.record, required this.isLocked});

  @override
  State<ShipmentRecordCard> createState() => _ShipmentRecordCardState();
}

class _ShipmentRecordCardState extends State<ShipmentRecordCard> {
  bool _expanded = false;

  static String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  bool _hasStr(String? v) => v != null && v.isNotEmpty;
  bool _hasNum(double? v) => v != null;
  bool _hasDate(DateTime? v) => v != null;

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final isLocked = widget.isLocked;

    final baseRows = <Widget>[
      if (_hasStr(r.exporterName)) _buildFieldRow('exporter_name'.tr(), r.exporterName!),
      if (_hasStr(r.exporterName)) const SizedBox(height: 8),
      if (_hasStr(r.countryOfOrigin)) _buildFieldRow('country_of_origin'.tr(), r.countryOfOrigin!),
      if (_hasStr(r.countryOfOrigin)) const SizedBox(height: 8),
      if (_hasStr(r.hsCode)) _buildFieldRow('hs_code'.tr(), r.hsCode!),
      if (_hasStr(r.hsCode)) const SizedBox(height: 8),
    ];

    final expandedRows = <Widget>[
      if (_hasStr(r.netWeight)) _buildFieldRow('net_weight'.tr(), r.netWeight!),
      if (_hasStr(r.netWeight)) const SizedBox(height: 8),
      if (_hasStr(r.netWeightUnit)) _buildFieldRow('net_weight_unit'.tr(), r.netWeightUnit!),
      if (_hasStr(r.netWeightUnit)) const SizedBox(height: 8),
      if (_hasStr(r.portOfArrival)) _buildFieldRow('port_of_arrival'.tr(), r.portOfArrival!),
      if (_hasStr(r.portOfArrival)) const SizedBox(height: 8),
      if (_hasStr(r.portOfDeparture)) _buildFieldRow('port_of_departure'.tr(), r.portOfDeparture!),
      if (_hasStr(r.portOfDeparture)) const SizedBox(height: 8),
      if (_hasStr(r.notifyParty)) _buildFieldRow('notify_party'.tr(), r.notifyParty!),
      if (_hasStr(r.notifyParty)) const SizedBox(height: 8),
      if (_hasStr(r.notifyAddress)) _buildFieldRow('notify_address'.tr(), r.notifyAddress!),
      if (_hasStr(r.notifyAddress)) const SizedBox(height: 8),
      if (_hasNum(r.quantity)) _buildFieldRow('quantity'.tr(), r.quantity!.toString()),
      if (_hasNum(r.quantity)) const SizedBox(height: 8),
      if (_hasNum(r.value)) _buildFieldRow('value'.tr(), r.value!.toString()),
      if (_hasNum(r.value)) const SizedBox(height: 8),
      if (_hasDate(r.unlockedAt)) _buildFieldRow('unlocked_at'.tr(), _formatDate(r.unlockedAt)),
      if (_hasDate(r.unlockedAt)) const SizedBox(height: 8),
      _buildFieldRow('id'.tr(), r.id),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...baseRows,
            if (_expanded) ...[
              if (baseRows.isNotEmpty || expandedRows.isNotEmpty) const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              ...expandedRows,
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Text(
                      _expanded ? 'show_less'.tr() : 'show_more'.tr(),
                      style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),
                isLocked
                    ? IconButton(
                        icon: const Icon(Icons.lock_open, color: AppTheme.primaryBlue, size: 20),
                        onPressed: () {
                          di.sl<SubscriptionCubit>().unlock(contentType: ContentType.shipmentRecords, targetId: r.id);
                        },
                      )
                    : const Icon(Icons.check_circle, color: Colors.green, size: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}

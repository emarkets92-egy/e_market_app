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

    // Build list of all fields with data
    final allFields = <Map<String, String>>[];
    
    if (_hasStr(r.exporterName)) allFields.add({'label': 'exporter_name'.tr(), 'value': r.exporterName!});
    if (_hasStr(r.countryOfOrigin)) allFields.add({'label': 'country_of_origin'.tr(), 'value': r.countryOfOrigin!});
    if (_hasStr(r.hsCode)) allFields.add({'label': 'hs_code'.tr(), 'value': r.hsCode!});
    if (_hasStr(r.productDetails)) allFields.add({'label': 'product_details'.tr(), 'value': r.productDetails!});
    if (_hasStr(r.netWeight)) allFields.add({'label': 'net_weight'.tr(), 'value': r.netWeight!});
    if (_hasStr(r.netWeightUnit)) allFields.add({'label': 'net_weight_unit'.tr(), 'value': r.netWeightUnit!});
    if (_hasStr(r.portOfArrival)) allFields.add({'label': 'port_of_arrival'.tr(), 'value': r.portOfArrival!});
    if (_hasStr(r.portOfDeparture)) allFields.add({'label': 'port_of_departure'.tr(), 'value': r.portOfDeparture!});
    if (_hasStr(r.notifyParty)) allFields.add({'label': 'notify_party'.tr(), 'value': r.notifyParty!});
    if (_hasStr(r.notifyAddress)) allFields.add({'label': 'notify_address'.tr(), 'value': r.notifyAddress!});
    if (_hasNum(r.quantity)) allFields.add({'label': 'quantity'.tr(), 'value': r.quantity!.toString()});
    if (_hasStr(r.quantityUnit)) allFields.add({'label': 'quantity_unit'.tr(), 'value': r.quantityUnit!});
    if (_hasNum(r.value)) allFields.add({'label': 'value'.tr(), 'value': r.value!.toString()});
    if (_hasNum(r.amountUsd)) allFields.add({'label': 'amount_usd'.tr(), 'value': '\$${r.amountUsd!.toStringAsFixed(2)}'});
    if (_hasNum(r.fobUsd)) allFields.add({'label': 'fob_usd'.tr(), 'value': '\$${r.fobUsd!.toStringAsFixed(2)}'});
    if (_hasNum(r.cifUsd)) allFields.add({'label': 'cif_usd'.tr(), 'value': '\$${r.cifUsd!.toStringAsFixed(2)}'});
    if (_hasDate(r.unlockedAt)) allFields.add({'label': 'unlocked_at'.tr(), 'value': _formatDate(r.unlockedAt)});

    // Show first 3 fields, rest in expanded
    final visibleFields = allFields.take(3).toList();
    final expandedFields = allFields.skip(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Visible fields
            ...visibleFields.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: entry.key < visibleFields.length - 1 ? 8 : 0),
                child: _buildFieldRow(entry.value['label']!, entry.value['value']!),
              );
            }),
            // Expanded fields
            if (_expanded && expandedFields.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              ...expandedFields.asMap().entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(bottom: entry.key < expandedFields.length - 1 ? 8 : 0),
                  child: _buildFieldRow(entry.value['label']!, entry.value['value']!),
                );
              }),
            ],
            // Actions row
            if (allFields.length > 3 || isLocked) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (allFields.length > 3)
                    InkWell(
                      onTap: () => setState(() => _expanded = !_expanded),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Text(
                          _expanded ? 'show_less'.tr() : 'show_more'.tr(),
                          style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ),
                    ),
                  if (allFields.length > 3 && isLocked) const SizedBox(width: 8),
                  if (isLocked)
                    InkWell(
                      onTap: () {
                        di.sl<SubscriptionCubit>().unlock(contentType: ContentType.shipmentRecords, targetId: r.id);
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.lock_open, color: AppTheme.primaryBlue, size: 16),
                      ),
                    ),
                  if (!isLocked && allFields.length <= 3)
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                ],
              ),
            ] else if (!isLocked) ...[
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.check_circle, color: Colors.green, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFieldRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            softWrap: true,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}

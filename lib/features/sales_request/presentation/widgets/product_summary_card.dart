import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/models/product_summary_model.dart';

class ProductSummaryCard extends StatelessWidget {
  final ProductSummaryModel product;
  final bool isSelected;
  final VoidCallback onTap;

  const ProductSummaryCard({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              if (product.hscode != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${'hs_code'.tr()}: ${product.hscode}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatChip(
                    context,
                    Icons.local_shipping,
                    '${product.totalShipmentRecords}',
                    'shipment_records'.tr(),
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    context,
                    Icons.import_export,
                    '${product.totalImporters}',
                    'importers'.tr(),
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    context,
                    Icons.upload,
                    '${product.totalExporters}',
                    'exporters'.tr(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String value, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text('$value $label', style: const TextStyle(fontSize: 12)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }
}

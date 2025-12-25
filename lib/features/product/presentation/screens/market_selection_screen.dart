import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_button.dart';

class MarketSelectionScreen extends StatelessWidget {
  final String productId;
  final int countryId;
  final String marketType;

  const MarketSelectionScreen({
    super.key,
    required this.productId,
    required this.countryId,
    required this.marketType,
  });

  @override
  Widget build(BuildContext context) {
    // Get user type from auth (simplified - should come from auth state)
    // For now, show both options
    final isExporter = true; // TODO: Get from auth state

    return Scaffold(
      appBar: AppBar(title: const Text('Market Selection')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Product ID: $productId',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Country ID: $countryId',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            if (isExporter && marketType == AppConstants.marketTypeTarget) ...[
              AppButton(
                text: 'Importer List',
                onPressed: () {
                  context.push(
                    '${RouteNames.profileList}?productId=$productId&countryId=$countryId&marketType=$marketType',
                  );
                },
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Analysis',
                onPressed: () {
                  context.push(
                    '${RouteNames.analysis}?productId=$productId&countryId=$countryId',
                  );
                },
              ),
            ] else if (isExporter && marketType == AppConstants.marketTypeOther) ...[
              AppButton(
                text: 'Importer List',
                onPressed: () {
                  context.push(
                    '${RouteNames.profileList}?productId=$productId&countryId=$countryId&marketType=$marketType',
                  );
                },
              ),
            ] else ...[
              // Importer
              AppButton(
                text: 'Exporter List',
                onPressed: () {
                  context.push(
                    '${RouteNames.profileList}?productId=$productId&countryId=$countryId&marketType=$marketType',
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}


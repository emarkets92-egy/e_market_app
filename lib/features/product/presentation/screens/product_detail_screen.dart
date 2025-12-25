import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/storage/local_storage.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/constants/app_constants.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    final locale = LocalStorage.getLocale();
    di.sl<ProductCubit>().getProductDetails(widget.productId, locale: locale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: BlocBuilder<ProductCubit, ProductState>(
        bloc: di.sl<ProductCubit>(),
        builder: (context, state) {
          if (state.isLoading && state.selectedProduct == null) {
            return const LoadingIndicator();
          }

          if (state.error != null && state.selectedProduct == null) {
            return AppErrorWidget(
              message: state.error!,
              onRetry: () {
                final locale = LocalStorage.getLocale();
                di.sl<ProductCubit>().getProductDetails(
                  widget.productId,
                  locale: locale,
                );
              },
            );
          }

          final product = state.selectedProduct;
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (product.hscode != null) ...[
                  const SizedBox(height: 8),
                  Text('HS Code: ${product.hscode}'),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Available Markets',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildMarketsList(context, product),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarketsList(BuildContext context, product) {
    // Get user type from auth state (simplified - you may want to store this better)
    // For now, show all markets
    final markets = <Map<String, dynamic>>[];

    if (product.targetMarkets.isNotEmpty) {
      markets.addAll(
        product.targetMarkets.map(
          (id) => {
            'id': id,
            'type': AppConstants.marketTypeTarget,
            'label': 'Target Market',
          },
        ),
      );
    }

    if (product.otherMarkets.isNotEmpty) {
      markets.addAll(
        product.otherMarkets.map(
          (id) => {
            'id': id,
            'type': AppConstants.marketTypeOther,
            'label': 'Other Market',
          },
        ),
      );
    }

    if (product.importerMarkets.isNotEmpty) {
      markets.addAll(
        product.importerMarkets.map(
          (id) => {
            'id': id,
            'type': AppConstants.marketTypeImporter,
            'label': 'Importer Market',
          },
        ),
      );
    }

    if (markets.isEmpty) {
      return const Text('No markets available');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: markets.length,
      itemBuilder: (context, index) {
        final market = markets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text('${market['label']} - Country ID: ${market['id']}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.push(
                '${RouteNames.marketSelection}?productId=${product.id}&countryId=${market['id']}&marketType=${market['type']}',
              );
            },
          ),
        );
      },
    );
  }
}

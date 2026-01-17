import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/storage/local_storage.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../cubit/sales_request_cubit.dart';
import '../cubit/sales_request_state.dart';
import '../widgets/product_summary_card.dart';

class ProductSelectionScreen extends StatefulWidget {
  final Function(List<String> selectedProductIds) onProductsSelected;

  const ProductSelectionScreen({
    super.key,
    required this.onProductsSelected,
  });

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final _refreshController = RefreshController(initialRefresh: false);
  final _hscodeController = TextEditingController();
  final _nameController = TextEditingController();
  final Set<String> _selectedProductIds = {};
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _hscodeController.dispose();
    _nameController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _loadProducts({bool refresh = false}) {
    if (refresh) {
      _currentPage = 1;
    }
    final locale = LocalStorage.getLocale();
    di.sl<SalesRequestCubit>().getProductsSummary(
      hscode: _hscodeController.text.trim().isEmpty ? null : _hscodeController.text.trim(),
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      page: _currentPage,
      locale: locale,
    );
  }

  void _onRefresh() {
    _loadProducts(refresh: true);
    _refreshController.refreshCompleted();
  }

  void _toggleProductSelection(String productId) {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
      } else {
        _selectedProductIds.add(productId);
      }
    });
  }

  void _onConfirmSelection() {
    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_select_at_least_one_product'.tr())),
      );
      return;
    }
    widget.onProductsSelected(_selectedProductIds.toList());
    // Navigation is handled by the callback in create_sales_request_screen.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('select_products'.tr()),
        actions: [
          TextButton(
            onPressed: _onConfirmSelection,
            child: Text('confirm'.tr()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hscodeController,
                    decoration: InputDecoration(
                      labelText: 'hs_code'.tr(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.qr_code),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'product_name'.tr(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _loadProducts(refresh: true),
                ),
              ],
            ),
          ),
          // Selected count
          if (_selectedProductIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                children: [
                  Text(
                    '${'selected'.tr()}: ${_selectedProductIds.length}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedProductIds.clear();
                      });
                    },
                    child: Text('clear'.tr()),
                  ),
                ],
              ),
            ),
          // Products list
          Expanded(
            child: BlocBuilder<SalesRequestCubit, SalesRequestState>(
              bloc: di.sl<SalesRequestCubit>(),
              builder: (context, state) {
                if (state.isLoading && state.products.isEmpty) {
                  return const LoadingIndicator();
                }

                if (state.error != null && state.products.isEmpty) {
                  return AppErrorWidget(
                    message: state.error!,
                    onRetry: () => _loadProducts(refresh: true),
                  );
                }

                if (state.products.isEmpty) {
                  return Center(child: Text('no_products_found'.tr()));
                }

                return SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  enablePullUp: _currentPage < state.totalPages,
                  onLoading: () {
                    if (_currentPage < state.totalPages) {
                      _currentPage++;
                      _loadProducts();
                      _refreshController.loadComplete();
                    } else {
                      _refreshController.loadNoData();
                    }
                  },
                  child: ListView.builder(
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return ProductSummaryCard(
                        product: product,
                        isSelected: _selectedProductIds.contains(product.id),
                        onTap: () => _toggleProductSelection(product.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

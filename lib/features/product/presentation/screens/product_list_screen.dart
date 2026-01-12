import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/storage/local_storage.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../widgets/product_card.dart';
import '../widgets/product_search_bar.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _refreshController = RefreshController(initialRefresh: false);
  final _hscodeController = TextEditingController();
  final _nameController = TextEditingController();
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
    di.sl<ProductCubit>().searchProducts(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('products'.tr())),
      body: Column(
        children: [
          ProductSearchBar(hscodeController: _hscodeController, nameController: _nameController, onSearch: () => _loadProducts(refresh: true)),
          Expanded(
            child: BlocBuilder<ProductCubit, ProductState>(
              bloc: di.sl<ProductCubit>(),
              builder: (context, state) {
                if (state.isLoading && state.products.isEmpty) {
                  return const LoadingIndicator();
                }

                if (state.error != null && state.products.isEmpty) {
                  return AppErrorWidget(message: state.error!, onRetry: () => _loadProducts(refresh: true));
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
                      return ProductCard(product: state.products[index]);
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

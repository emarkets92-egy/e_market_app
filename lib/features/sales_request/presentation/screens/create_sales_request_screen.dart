import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../cubit/sales_request_cubit.dart';
import '../cubit/sales_request_state.dart';
import '../../data/models/create_sales_request_model.dart';
import 'product_selection_screen.dart';
import '../../../../shared/widgets/about_us_section.dart';
import '../../../../shared/widgets/contact_us_section.dart';

class CreateSalesRequestScreen extends StatefulWidget {
  const CreateSalesRequestScreen({super.key});

  @override
  State<CreateSalesRequestScreen> createState() => _CreateSalesRequestScreenState();
}

class _CreateSalesRequestScreenState extends State<CreateSalesRequestScreen> {
  final _notesController = TextEditingController();
  final List<String> _selectedProductIds = [];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectProducts() async {
    final selectedIds = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: di.sl<SalesRequestCubit>(),
          child: ProductSelectionScreen(
            onProductsSelected: (ids) {
              Navigator.of(context).pop(ids);
            },
          ),
        ),
      ),
    );

    if (selectedIds != null) {
      setState(() {
        _selectedProductIds.clear();
        _selectedProductIds.addAll(selectedIds);
      });
    }
  }

  void _createSalesRequest() {
    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_select_at_least_one_product'.tr())),
      );
      return;
    }

    final request = CreateSalesRequestModel(
      productIds: _selectedProductIds,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    di.sl<SalesRequestCubit>().createSalesRequest(request);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('create_sales_request'.tr()),
      ),
      body: BlocListener<SalesRequestCubit, SalesRequestState>(
        bloc: di.sl<SalesRequestCubit>(),
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
          // Success - navigate to list
          if (!state.isLoading && state.error == null && state.salesRequests.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('sales_request_created_successfully'.tr())),
            );
            context.go(RouteNames.salesRequestList);
          }
        },
        child: BlocBuilder<SalesRequestCubit, SalesRequestState>(
          bloc: di.sl<SalesRequestCubit>(),
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product selection section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'selected_products'.tr(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          if (_selectedProductIds.isEmpty)
                            Text(
                              'no_products_selected'.tr(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedProductIds.map((id) {
                                return Chip(
                                  label: Text(id.substring(0, 8)),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedProductIds.remove(id);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _selectProducts,
                            icon: const Icon(Icons.add_shopping_cart),
                            label: Text(_selectedProductIds.isEmpty ? 'select_products'.tr() : 'change_products'.tr()),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Notes section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'notes'.tr(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _notesController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'add_notes_about_your_interest'.tr(),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Submit button
                  ElevatedButton(
                    onPressed: state.isLoading ? null : _createSalesRequest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('create_request'.tr()),
                  ),
                  const SizedBox(height: 48),
                  // About Us Section
                  const AboutUsSection(),
                  const SizedBox(height: 32),
                  // Contact Us Section
                  const ContactUsSection(),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../cubit/sales_request_cubit.dart';
import '../cubit/sales_request_state.dart';
import '../../../../shared/widgets/about_us_section.dart';
import '../../../../shared/widgets/contact_us_section.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class SalesRequestListScreen extends StatefulWidget {
  const SalesRequestListScreen({super.key});

  @override
  State<SalesRequestListScreen> createState() => _SalesRequestListScreenState();
}

class _SalesRequestListScreenState extends State<SalesRequestListScreen> {
  @override
  void initState() {
    super.initState();
    di.sl<SalesRequestCubit>().getSalesRequests();
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'pending'.tr();
      case 'contacted':
        return 'contacted'.tr();
      case 'converted':
        return 'converted'.tr();
      case 'rejected':
        return 'rejected'.tr();
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'contacted':
        return Colors.blue;
      case 'converted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_sales_requests'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.go(RouteNames.salesRequestCreate);
            },
            tooltip: 'create_new_request'.tr(),
          ),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await di.sl<AuthCubit>().logout();
              if (context.mounted) {
                context.go(RouteNames.login);
              }
            },
            tooltip: 'logout'.tr(),
          ),
        ],
      ),
      body: BlocBuilder<SalesRequestCubit, SalesRequestState>(
        bloc: di.sl<SalesRequestCubit>(),
        builder: (context, state) {
          if (state.isLoading && state.salesRequests.isEmpty) {
            return const LoadingIndicator();
          }

          if (state.error != null && state.salesRequests.isEmpty) {
            return AppErrorWidget(
              message: state.error!,
              onRetry: () => di.sl<SalesRequestCubit>().getSalesRequests(),
            );
          }

          if (state.salesRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'no_sales_requests'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'create_your_first_sales_request'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go(RouteNames.salesRequestCreate);
                    },
                    icon: const Icon(Icons.add),
                    label: Text('create_request'.tr()),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await di.sl<SalesRequestCubit>().getSalesRequests();
            },
            child: ListView(
              children: [
                ...List.generate(
                  state.salesRequests.length,
                  (index) {
                    final request = state.salesRequests[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          '${'request'.tr()} #${request.id.substring(0, 8)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('${'products'.tr()}: ${request.productIds.length}'),
                            if (request.notes != null && request.notes!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                request.notes!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              '${'created'.tr()}: ${_formatDate(request.createdAt)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(_getStatusLabel(request.status)),
                          backgroundColor: _getStatusColor(request.status).withOpacity(0.2),
                          labelStyle: TextStyle(color: _getStatusColor(request.status)),
                        ),
                        onTap: () {
                          // Navigate to detail screen if needed
                          // context.push(RouteNames.salesRequestDetail(request.id));
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                // About Us Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: AboutUsSection(),
                ),
                const SizedBox(height: 32),
                // Contact Us Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ContactUsSection(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(RouteNames.salesRequestCreate);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

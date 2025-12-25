import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../../../points/presentation/widgets/points_display.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../subscription/presentation/cubit/subscription_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load user from storage (important for hot restart)
    di.sl<AuthCubit>().checkAuthStatus();
    // Load subscriptions
    di.sl<SubscriptionCubit>().getSubscriptions(activeOnly: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Market'),
        actions: [
          Padding(padding: const EdgeInsets.all(8.0), child: PointsDisplay()),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await di.sl<AuthCubit>().logout();
              if (context.mounted) {
                // Navigation will be handled by router redirect
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        bloc: di.sl<AuthCubit>(),
        builder: (context, state) {
          if (state.user == null) {
            return const Center(child: Text('Welcome!'));
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome, ${state.user?.name ?? state.user?.email ?? "User"}!',
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.push(RouteNames.subscriptionSelection);
                  },
                  child: const Text('Browse Products'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

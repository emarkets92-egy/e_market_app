import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../../../points/presentation/widgets/points_display.dart';
import '../widgets/search_bar.dart' as home_widgets;
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../points/presentation/cubit/points_cubit.dart';
import '../../../points/presentation/cubit/points_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load points balance
    di.sl<PointsCubit>().getBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Market'),
        actions: [
          BlocBuilder<PointsCubit, PointsState>(
            bloc: di.sl<PointsCubit>(),
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: PointsDisplay(),
              );
            },
          ),
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
      body: Column(
        children: [
          const home_widgets.SearchBar(),
          Expanded(
            child: BlocBuilder<AuthCubit, AuthState>(
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
                          context.push(RouteNames.productList);
                        },
                        child: const Text('Browse Products'),
                      ),
                    ],
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

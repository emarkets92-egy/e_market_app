import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/register_form.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../localization/presentation/cubit/localization_cubit.dart';
import '../../../localization/presentation/cubit/localization_state.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: BlocBuilder<LocalizationCubit, LocalizationState>(
        bloc: di.sl<LocalizationCubit>(),
        builder: (context, localizationState) {
          if (localizationState.countries.isEmpty) {
            di.sl<LocalizationCubit>().loadCountries();
          }

          return BlocConsumer<AuthCubit, AuthState>(
            bloc: di.sl<AuthCubit>(),
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
              }
              if (state.isAuthenticated && state.user != null) {
                context.go(RouteNames.home);
              }
            },
            builder: (context, state) {
              if (state.isLoading) {
                return const LoadingIndicator();
              }

              final countries = localizationState.countries.map((c) => {'id': c.id, 'name': c.name}).toList();

              return SingleChildScrollView(
                child: RegisterForm(
                  onRegister: (request) {
                    di.sl<AuthCubit>().completeProfile(request);
                  },
                  countries: countries,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

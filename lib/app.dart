import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'config/theme.dart';
import 'config/routes/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/product/presentation/cubit/product_cubit.dart';
import 'features/subscription/presentation/cubit/subscription_cubit.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/localization/presentation/cubit/localization_cubit.dart';
import 'shared/widgets/auth_init_wrapper.dart';
import 'shared/widgets/version_check_wrapper.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: di.sl<AuthCubit>()),
        BlocProvider.value(value: di.sl<ProductCubit>()),
        BlocProvider.value(value: di.sl<SubscriptionCubit>()),
        BlocProvider.value(value: di.sl<HomeCubit>()),
        BlocProvider.value(value: di.sl<LocalizationCubit>()),
      ],
      child: VersionCheckWrapper(
        child: AuthInitWrapper(
          child: MaterialApp.router(
            title: 'app_name'.tr(),
            theme: AppTheme.lightTheme.copyWith(scaffoldBackgroundColor: Colors.white),
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routerConfig: appRouter,
          ),
        ),
      ),
    );
  }
}

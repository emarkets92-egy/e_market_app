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
import 'features/locale/presentation/cubit/locale_cubit.dart';
import 'features/locale/presentation/cubit/locale_state.dart';
import 'features/chat/presentation/cubit/chat_cubit.dart';
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
        BlocProvider.value(value: di.sl<LocaleCubit>()),
        BlocProvider.value(value: di.sl<ChatCubit>()),
      ],
      child: BlocListener<LocaleCubit, LocaleState>(
        listener: (context, state) {
          // Update EasyLocalization context when locale changes
          if (context.mounted && context.locale != state.locale) {
            context.setLocale(state.locale);
          }
        },
        child: BlocBuilder<LocaleCubit, LocaleState>(
          builder: (context, localeState) {
            return VersionCheckWrapper(
              child: AuthInitWrapper(
                child: MaterialApp.router(
                  key: ValueKey(localeState.locale.languageCode), // Force rebuild on locale change
                  title: 'app_name'.tr(),
                  theme: AppTheme.lightTheme.copyWith(scaffoldBackgroundColor: Colors.white),
                  debugShowCheckedModeBanner: false,
                  themeMode: ThemeMode.light,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: localeState.locale,
                  routerConfig: appRouter,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

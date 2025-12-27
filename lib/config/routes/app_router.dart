import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/storage/secure_storage.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/product/presentation/cubit/product_cubit.dart';
import '../../features/subscription/presentation/cubit/subscription_cubit.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/complete_profile_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/inbox_screen.dart';
import '../../features/home/presentation/screens/opportunities_screen.dart';
import '../../features/home/presentation/screens/notifications_screen.dart';
import '../../features/home/presentation/screens/profile_screen.dart';
import '../../features/product/presentation/screens/product_list_screen.dart';
import '../../features/product/presentation/screens/product_detail_screen.dart';
import '../../features/product/presentation/screens/market_selection_screen.dart';
import '../../features/subscription/presentation/screens/profile_list_screen.dart';
import '../../features/subscription/presentation/screens/profile_detail_screen.dart';
import '../../features/subscription/presentation/screens/shipment_records_list_screen.dart';
import '../../features/subscription/presentation/screens/analysis_screen.dart';
import '../../features/subscription/presentation/screens/competitive_analysis_screen.dart';
import '../../features/subscription/presentation/screens/pestle_analysis_screen.dart';
import '../../features/subscription/presentation/screens/swot_analysis_screen.dart';
import '../../features/subscription/presentation/screens/market_plan_screen.dart';
import '../../features/subscription/presentation/screens/subscription_selection_screen.dart';
import 'route_names.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.login,
  redirect: (context, state) async {
    final isAuthenticated = await SecureStorage.getAccessToken() != null;
    final isLoginRoute =
        state.matchedLocation == RouteNames.login ||
        state.matchedLocation == RouteNames.register;

    if (!isAuthenticated && !isLoginRoute) {
      return RouteNames.login;
    }

    if (isAuthenticated && isLoginRoute) {
      return RouteNames.home;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<AuthCubit>(),
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<AuthCubit>(),
        child: const RegisterScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.completeProfile,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<AuthCubit>(),
        child: const CompleteProfileScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: di.sl<HomeCubit>()),
          BlocProvider.value(value: di.sl<SubscriptionCubit>()),
        ],
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.inbox,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: di.sl<HomeCubit>()),
        ],
        child: const InboxScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.opportunities,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: di.sl<HomeCubit>()),
        ],
        child: const OpportunitiesScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.notifications,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: di.sl<HomeCubit>()),
        ],
        child: const NotificationsScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.profile,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: di.sl<HomeCubit>()),
        ],
        child: const ProfileScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.subscriptionSelection,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<SubscriptionCubit>(),
        child: const SubscriptionSelectionScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.productList,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<ProductCubit>(),
        child: const ProductListScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.productDetail,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<ProductCubit>(),
        child: ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: RouteNames.marketSelection,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<ProductCubit>(),
        child: MarketSelectionScreen(
          productId: state.uri.queryParameters['productId']!,
          countryId: int.parse(state.uri.queryParameters['countryId']!),
          marketType: state.uri.queryParameters['marketType']!,
        ),
      ),
    ),
    GoRoute(
      path: RouteNames.profileList,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<SubscriptionCubit>(),
        child: ProfileListScreen(
          productId: state.uri.queryParameters['productId']!,
          countryId: int.parse(state.uri.queryParameters['countryId']!),
          marketType: state.uri.queryParameters['marketType']!,
        ),
      ),
    ),
    GoRoute(
      path: RouteNames.profileDetail,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<SubscriptionCubit>(),
        child: ProfileDetailScreen(profileId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: RouteNames.shipmentRecordsList,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<SubscriptionCubit>(),
        child: ShipmentRecordsListScreen(
          profileId: state.pathParameters['profileId']!,
        ),
      ),
    ),
    GoRoute(
      path: RouteNames.analysis,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<SubscriptionCubit>(),
        child: AnalysisScreen(
          productId: state.uri.queryParameters['productId']!,
          countryId: int.parse(state.uri.queryParameters['countryId']!),
        ),
      ),
    ),
    GoRoute(
      path: RouteNames.competitiveAnalysis,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<SubscriptionCubit>(),
        child: CompetitiveAnalysisScreen(
          productId: state.uri.queryParameters['productId']!,
          countryId: int.parse(state.uri.queryParameters['countryId']!),
        ),
      ),
    ),
    GoRoute(
      path: RouteNames.pestleAnalysis,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<SubscriptionCubit>(),
        child: PESTLEAnalysisScreen(
          productId: state.uri.queryParameters['productId']!,
          countryId: int.parse(state.uri.queryParameters['countryId']!),
        ),
      ),
    ),
    GoRoute(
      path: RouteNames.swotAnalysis,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<SubscriptionCubit>(),
        child: SWOTAnalysisScreen(
          productId: state.uri.queryParameters['productId']!,
          countryId: int.parse(state.uri.queryParameters['countryId']!),
        ),
      ),
    ),
    GoRoute(
      path: RouteNames.marketPlan,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<SubscriptionCubit>(),
        child: MarketPlanScreen(
          productId: state.uri.queryParameters['productId']!,
          countryId: int.parse(state.uri.queryParameters['countryId']!),
        ),
      ),
    ),
  ],
);

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
import '../../features/product/presentation/screens/product_list_screen.dart';
import '../../features/product/presentation/screens/product_detail_screen.dart';
import '../../features/product/presentation/screens/market_selection_screen.dart';
import '../../features/subscription/presentation/screens/profile_list_screen.dart';
import '../../features/subscription/presentation/screens/profile_detail_screen.dart';
import '../../features/subscription/presentation/screens/analysis_screen.dart';
import '../../features/subscription/presentation/screens/subscription_selection_screen.dart';
import '../../features/chat/presentation/screens/conversations_list_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/search_unlocked_profiles_screen.dart';
import '../../features/chat/presentation/cubit/chat_cubit.dart';
import '../../features/sales_request/presentation/screens/create_sales_request_screen.dart';
import '../../features/sales_request/presentation/screens/sales_request_list_screen.dart';
import '../../features/sales_request/presentation/cubit/sales_request_cubit.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/notifications/presentation/cubit/notification_cubit.dart';
import 'route_names.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.login,
  redirect: (context, state) async {
    final isAuthenticated = await SecureStorage.getAccessToken() != null;
    final isLoginRoute = state.matchedLocation == RouteNames.login || state.matchedLocation == RouteNames.register;
    final isCompleteProfileRoute = state.matchedLocation == RouteNames.completeProfile;
    final isSalesRequestRoute = state.matchedLocation == RouteNames.salesRequestCreate || 
                                state.matchedLocation == RouteNames.salesRequestList;

    if (!isAuthenticated && !isLoginRoute && !isCompleteProfileRoute) {
      return RouteNames.login;
    }

    if (isAuthenticated && isLoginRoute) {
      // Check subscription status from AuthCubit
      final authCubit = di.sl<AuthCubit>();
      final authState = authCubit.state;
      
      // If user is loaded and not subscribed, redirect to sales request flow
      if (authState.user != null && !authState.user!.isUserSubscribed) {
        // Allow navigation to sales request routes
        if (isSalesRequestRoute) {
          return null;
        }
        return RouteNames.salesRequestCreate;
      }
      
      // If subscribed, go to home
      if (authState.user != null && authState.user!.isUserSubscribed) {
        return RouteNames.home;
      }
      
      // If user not loaded yet, go to home (will be redirected by AuthInitWrapper if needed)
      return RouteNames.home;
    }

    return null;
  },
  routes: [
    // Root entry for hosting under `/app/` (and for deep-link refreshes).
    GoRoute(
      path: '/',
      redirect: (context, state) => RouteNames.home,
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => BlocProvider.value(value: di.sl<AuthCubit>(), child: const LoginScreen()),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => BlocProvider.value(value: di.sl<AuthCubit>(), child: const RegisterScreen()),
    ),
    GoRoute(
      path: RouteNames.completeProfile,
      builder: (context, state) => BlocProvider.value(value: di.sl<AuthCubit>(), child: const CompleteProfileScreen()),
    ),
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: di.sl<HomeCubit>()),
          BlocProvider.value(value: di.sl<SubscriptionCubit>()),
        ],
        child: HomeScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.inbox,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: di.sl<HomeCubit>()),
          BlocProvider.value(value: di.sl<ChatCubit>()),
        ],
        child: const ConversationsListScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.notifications,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: di.sl<HomeCubit>()),
          BlocProvider.value(value: di.sl<NotificationCubit>()),
        ],
        child: const NotificationsScreen(),
      ),
    ),
    // More specific route must come before parameterized route
    GoRoute(
      path: RouteNames.searchUnlockedProfiles,
      builder: (context, state) => MultiBlocProvider(
        providers: [BlocProvider.value(value: di.sl<ChatCubit>())],
        child: const SearchUnlockedProfilesScreen(),
      ),
    ),
    GoRoute(
      path: '${RouteNames.chat}/:roomId',
      builder: (context, state) => MultiBlocProvider(
        providers: [BlocProvider.value(value: di.sl<ChatCubit>())],
        child: ChatScreen(roomId: state.pathParameters['roomId'], recipientProfileId: state.uri.queryParameters['recipientProfileId']),
      ),
    ),
    GoRoute(
      path: RouteNames.chat,
      builder: (context, state) => MultiBlocProvider(
        providers: [BlocProvider.value(value: di.sl<ChatCubit>())],
        child: ChatScreen(roomId: null, recipientProfileId: state.uri.queryParameters['recipientProfileId']),
      ),
    ),
    GoRoute(
      path: RouteNames.subscriptionSelection,
      builder: (context, state) => BlocProvider.value(value: di.sl<SubscriptionCubit>(), child: const SubscriptionSelectionScreen()),
    ),
    GoRoute(
      path: RouteNames.productList,
      builder: (context, state) => BlocProvider.value(value: di.sl<ProductCubit>(), child: const ProductListScreen()),
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
      path: RouteNames.analysis,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<SubscriptionCubit>(),
        child: AnalysisScreen(productId: state.uri.queryParameters['productId']!, countryId: int.parse(state.uri.queryParameters['countryId']!)),
      ),
    ),
    // Sales Request routes
    GoRoute(
      path: RouteNames.salesRequestCreate,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<SalesRequestCubit>(),
        child: const CreateSalesRequestScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.salesRequestList,
      builder: (context, state) => BlocProvider.value(
        value: di.sl<SalesRequestCubit>(),
        child: const SalesRequestListScreen(),
      ),
    ),
  ],
);

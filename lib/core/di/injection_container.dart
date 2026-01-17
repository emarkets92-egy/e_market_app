import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/interceptors.dart';
import '../storage/secure_storage.dart';
import '../storage/local_storage.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

// Product
import '../../features/product/data/datasources/product_remote_datasource.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/presentation/cubit/product_cubit.dart';

// Localization
import '../../features/localization/data/datasources/localization_remote_datasource.dart';
import '../../features/localization/data/repositories/localization_repository_impl.dart';
import '../../features/localization/domain/repositories/localization_repository.dart';
import '../../features/localization/presentation/cubit/localization_cubit.dart';

// Subscription
import '../../features/subscription/data/datasources/subscription_remote_datasource.dart';
import '../../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../../features/subscription/domain/repositories/subscription_repository.dart';
import '../../features/subscription/presentation/cubit/subscription_cubit.dart';

// Home
import '../../features/home/presentation/cubit/home_cubit.dart';

// Locale
import '../../features/locale/presentation/cubit/locale_cubit.dart';

// Version
import '../../features/version/data/datasources/version_remote_datasource.dart';
import '../../features/version/data/repositories/version_repository_impl.dart';
import '../../features/version/domain/repositories/version_repository.dart';
import '../../features/version/presentation/cubit/version_cubit.dart';

// Chat
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/presentation/cubit/chat_cubit.dart';
import '../../features/chat/presentation/services/chat_polling_service.dart';

// Sales Request
import '../../features/sales_request/data/datasources/sales_request_remote_datasource.dart';
import '../../features/sales_request/data/repositories/sales_request_repository_impl.dart';
import '../../features/sales_request/domain/repositories/sales_request_repository.dart';
import '../../features/sales_request/presentation/cubit/sales_request_cubit.dart';

// Notifications
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/cubit/notification_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize LocalStorage
  await LocalStorage.init();

  // Core
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage());
  sl.registerLazySingleton<LocalStorage>(() => LocalStorage());

  // Network
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(ErrorInterceptor());
    dio.interceptors.add(LoggingInterceptor());
    return dio;
  });

  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<Dio>()));

  // Data Sources - Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl<ApiClient>()));
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl());

  // Data Sources - Product
  sl.registerLazySingleton<ProductRemoteDataSource>(() => ProductRemoteDataSourceImpl(sl<ApiClient>()));

  // Data Sources - Localization
  sl.registerLazySingleton<LocalizationRemoteDataSource>(() => LocalizationRemoteDataSourceImpl(sl<ApiClient>()));

  // Data Sources - Subscription
  sl.registerLazySingleton<SubscriptionRemoteDataSource>(() => SubscriptionRemoteDataSourceImpl(sl<ApiClient>()));

  // Data Sources - Version
  sl.registerLazySingleton<VersionRemoteDataSource>(() => VersionRemoteDataSourceImpl(sl<ApiClient>()));

  // Data Sources - Chat
  sl.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl(sl<ApiClient>()));

  // Data Sources - Sales Request
  sl.registerLazySingleton<SalesRequestRemoteDataSource>(() => SalesRequestRemoteDataSourceImpl(sl<ApiClient>()));

  // Data Sources - Notifications
  sl.registerLazySingleton<NotificationRemoteDataSource>(() => NotificationRemoteDataSourceImpl(sl<ApiClient>()));

  // Repositories - Auth
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>(), localDataSource: sl<AuthLocalDataSource>()));

  // Repositories - Product
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(remoteDataSource: sl<ProductRemoteDataSource>()));

  // Repositories - Localization
  sl.registerLazySingleton<LocalizationRepository>(() => LocalizationRepositoryImpl(remoteDataSource: sl<LocalizationRemoteDataSource>()));

  // Repositories - Subscription
  sl.registerLazySingleton<SubscriptionRepository>(() => SubscriptionRepositoryImpl(remoteDataSource: sl<SubscriptionRemoteDataSource>()));

  // Repositories - Version
  sl.registerLazySingleton<VersionRepository>(() => VersionRepositoryImpl(remoteDataSource: sl<VersionRemoteDataSource>()));

  // Repositories - Chat
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(remoteDataSource: sl<ChatRemoteDataSource>()));

  // Repositories - Sales Request
  sl.registerLazySingleton<SalesRequestRepository>(() => SalesRequestRepositoryImpl(remoteDataSource: sl<SalesRequestRemoteDataSource>()));

  // Repositories - Notifications
  sl.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(remoteDataSource: sl<NotificationRemoteDataSource>()));

  // Cubits - Register as lazy singletons
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl<AuthRepository>()));

  sl.registerLazySingleton<ProductCubit>(() => ProductCubit(sl<ProductRepository>()));

  sl.registerLazySingleton<LocalizationCubit>(() => LocalizationCubit(sl<LocalizationRepository>()));

  sl.registerLazySingleton<SubscriptionCubit>(() => SubscriptionCubit(sl<SubscriptionRepository>()));

  sl.registerLazySingleton<HomeCubit>(() => HomeCubit());

  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit());

  sl.registerLazySingleton<VersionCubit>(() => VersionCubit(versionRepository: sl<VersionRepository>()));

  sl.registerLazySingleton<ChatCubit>(() => ChatCubit(sl<ChatRepository>()));

  sl.registerLazySingleton<SalesRequestCubit>(() => SalesRequestCubit(sl<SalesRequestRepository>()));

  sl.registerLazySingleton<NotificationCubit>(() => NotificationCubit(sl<NotificationRepository>()));

  sl.registerLazySingleton<ChatPollingService>(() => ChatPollingService(sl<ChatCubit>()));
}

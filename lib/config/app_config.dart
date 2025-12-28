class AppConfig {
  // API Configuration
  // local
  static const String apiBaseUrl = 'http://192.168.1.6:3000';

  // production
  // static const String apiBaseUrl = 'https://e-market-backend-vaph.onrender.com';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // App Constants
  static const String appName = 'E-Market';
  static const String appVersion = '1.0.0';

  // Pagination defaults
  static const int defaultPageSize = 20;
  static const int defaultPage = 1;

  // Locale defaults
  static const String defaultLocale = 'en';
  static const List<String> supportedLocales = ['en', 'ar'];
}

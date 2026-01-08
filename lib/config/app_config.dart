class AppConfig {
  // local
  // static const String apiBaseUrl = 'http://192.168.1.6:3000';

  // production
  static const String apiBaseUrl = 'https://e-market-backend-vaph.onrender.com';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const String defaultLocale = 'en';
  static const List<String> supportedLocales = ['en', 'ar'];
}

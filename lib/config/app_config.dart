class AppConfig {
  // local
  // static const String apiBaseUrl = 'http://192.168.1.2:3000';

  // production
  static const String apiBaseUrl = 'https://e-market-backend-vaph.onrender.com';

  static const Duration connectTimeout = Duration(minutes: 2);
  static const Duration receiveTimeout = Duration(minutes: 2);
  static const String defaultLocale = 'en';
  static const List<String> supportedLocales = ['en', 'ar', 'fr', 'it', 'es'];
}

class AppConfig {
  // local
  // static const String apiBaseUrl = 'http://192.168.1.2:3000';

  // production (Render). For Flutter web to work, backend must send CORS headers:
  // Access-Control-Allow-Origin and allow GET/POST/etc for your web app origin.
  static const String apiBaseUrl = 'https://e-market-backend-vaph.onrender.com';

  static const Duration connectTimeout = Duration(minutes: 2);
  static const Duration receiveTimeout = Duration(minutes: 2);
  static const String defaultLocale = 'en';
  static const List<String> supportedLocales = ['en', 'ar', 'fr', 'it', 'es'];

  /// Minimum viewport width (logical px) to consider as "desktop" layout.
  /// Below this, the app shows "use desktop only" and blocks interaction.
  static const double desktopMinWidth = 1024;
}

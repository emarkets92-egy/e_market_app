import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../config/app_config.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorage not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Locale
  static Future<void> saveLocale(String locale) async {
    await prefs.setString(AppConstants.keyLocale, locale);
  }

  static String getLocale() {
    return prefs.getString(AppConstants.keyLocale) ?? AppConfig.defaultLocale;
  }

  // User data (cached)
  static Future<void> saveUser(String userJson) async {
    await prefs.setString(AppConstants.keyUser, userJson);
  }

  static String? getUser() {
    return prefs.getString(AppConstants.keyUser);
  }

  static Future<void> clearUser() async {
    await prefs.remove(AppConstants.keyUser);
  }

  // Generic helpers
  static Future<void> clearAll() async {
    await prefs.clear();
  }
}

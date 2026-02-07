import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/di/injection_container.dart' as di;
import 'app.dart';
import 'core/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use clean path URLs on web (no #/). Requires host rewrite rules.
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  await di.init();
  await LocalStorage.init();

  // Initialize easy_localization
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('fr'), Locale('it'), Locale('es')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: Locale(LocalStorage.getLocale()),
      useOnlyLangCode: true,
      child: const MyApp(),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/di/injection_container.dart' as di;
import 'app.dart';
import 'config/app_config.dart';
import 'core/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      child: const MyApp(),
    ),
  );
}

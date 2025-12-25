import 'package:flutter/material.dart';
import 'en/strings.dart' as en;
import 'ar/strings.dart' as ar;

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  Map<String, String> get _localizedStrings {
    switch (locale.languageCode) {
      case 'ar':
        return ar.strings;
      case 'en':
      default:
        return en.strings;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Convenience getters
  String get appName => translate('app_name');
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get name => translate('name');
  String get companyName => translate('company_name');
  String get phone => translate('phone');
  String get whatsapp => translate('whatsapp');
  String get website => translate('website');
  String get address => translate('address');
  String get country => translate('country');
  String get userType => translate('user_type');
  String get importer => translate('importer');
  String get exporter => translate('exporter');
  String get submit => translate('submit');
  String get cancel => translate('cancel');
  String get search => translate('search');
  String get home => translate('home');
  String get products => translate('products');
  String get points => translate('points');
  String get balance => translate('balance');
  String get unlock => translate('unlock');
  String get unlocked => translate('unlocked');
  String get loading => translate('loading');
  String get error => translate('error');
  String get retry => translate('retry');
  String get logout => translate('logout');
  String get profile => translate('profile');
  String get analysis => translate('analysis');
  String get competitiveAnalysis => translate('competitive_analysis');
  String get pestleAnalysis => translate('pestle_analysis');
  String get swotAnalysis => translate('swot_analysis');
  String get marketPlan => translate('market_plan');
  String get insufficientBalance => translate('insufficient_balance');
  String get unlockCost => translate('unlock_cost');
  String get credits => translate('credits');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}


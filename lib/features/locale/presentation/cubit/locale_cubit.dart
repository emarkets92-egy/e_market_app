import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/local_storage.dart';
import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(LocaleState(Locale(LocalStorage.getLocale())));

  Future<void> changeLocale(Locale locale) async {
    await LocalStorage.saveLocale(locale.languageCode);
    emit(LocaleState(locale));
  }

  Future<void> changeLocaleByCode(String languageCode) async {
    await changeLocale(Locale(languageCode));
  }
}

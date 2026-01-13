import 'package:flutter/material.dart';

class LocaleState {
  final Locale locale;

  const LocaleState(this.locale);

  LocaleState copyWith({Locale? locale}) {
    return LocaleState(locale ?? this.locale);
  }
}

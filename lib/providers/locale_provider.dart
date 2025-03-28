import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netverify/providers/storage_provider.dart';
import 'dart:ui';

final localeProvider = StateNotifierProvider<LocaleProvider, Locale?>((ref) {
  return LocaleProvider(ref);
});

class LocaleProvider extends StateNotifier<Locale?> {
  final Ref ref;

  LocaleProvider(this.ref) : super(null) {
    _loadLocale();
  }

  static const _localeKey = 'locale';
  Future<void> _loadLocale() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final localeCode = prefs.getString(_localeKey);
    state =
        (localeCode != null && localeCode != "system")
            ? Locale(localeCode)
            : null;
  }

  Future<void> _saveLocale(Locale? locale) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_localeKey, locale?.languageCode ?? "system");
  }

  void setLocale(Locale? locale) {
    state = locale;
    _saveLocale(locale);
  }

  void resetToSystemLocale() {
    state = null;
    _saveLocale(null);
  }
}

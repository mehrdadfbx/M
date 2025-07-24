import 'package:flutter/material.dart';
import 'package:finance/services/preferences_service.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final localeCode = await PreferencesService.getLocale();
    _locale = Locale(localeCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await PreferencesService.setLocale(locale.languageCode);
    notifyListeners();
  }

  bool get isRTL => _locale.languageCode == 'fa';
}

import 'package:flutter/material.dart';
import 'package:finance/services/preferences_service.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _isDarkMode = await PreferencesService.getIsDarkMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await PreferencesService.setIsDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool isDarkMode) async {
    _isDarkMode = isDarkMode;
    await PreferencesService.setIsDarkMode(_isDarkMode);
    notifyListeners();
  }
}

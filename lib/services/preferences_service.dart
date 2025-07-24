import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance/models/budget.dart';

class PreferencesService {
  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'locale';
  static const String _currencyKey = 'currency';
  static const String _monthlyIncomeKey = 'monthly_income';
  static const String _spendingLimitKey = 'spending_limit';
  static const String _notificationsKey = 'notifications_enabled';

  static Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  // Theme
  static Future<bool> getIsDarkMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_themeKey) ?? false;
  }

  static Future<void> setIsDarkMode(bool isDarkMode) async {
    final prefs = await _prefs;
    await prefs.setBool(_themeKey, isDarkMode);
  }

  // Locale
  static Future<String> getLocale() async {
    final prefs = await _prefs;
    return prefs.getString(_localeKey) ?? 'en';
  }

  static Future<void> setLocale(String locale) async {
    final prefs = await _prefs;
    await prefs.setString(_localeKey, locale);
  }

  // Currency
  static Future<String> getCurrency() async {
    final prefs = await _prefs;
    return prefs.getString(_currencyKey) ?? 'toman';
  }

  static Future<void> setCurrency(String currency) async {
    final prefs = await _prefs;
    await prefs.setString(_currencyKey, currency);
  }

  // Budget
  static Future<BudgetModel> getBudget() async {
    final prefs = await _prefs;
    return BudgetModel(
      monthlyIncome: prefs.getDouble(_monthlyIncomeKey) ?? 0.0,
      spendingLimit: prefs.getDouble(_spendingLimitKey) ?? 0.0,
      currency: await getCurrency(),
    );
  }

  static Future<void> setBudget(BudgetModel budget) async {
    final prefs = await _prefs;
    await prefs.setDouble(_monthlyIncomeKey, budget.monthlyIncome);
    await prefs.setDouble(_spendingLimitKey, budget.spendingLimit);
    await setCurrency(budget.currency);
  }

  // Notifications
  static Future<bool> getNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_notificationsKey) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_notificationsKey, enabled);
  }
}

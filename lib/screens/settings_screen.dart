import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:finance/providers/theme_provider.dart';
import 'package:finance/providers/locale_provider.dart';
import 'package:finance/providers/finance_provider.dart';
import 'package:finance/models/budget.dart';
import 'package:finance/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _incomeController = TextEditingController();
  final _limitController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _loadBudgetData() {
    final financeProvider = Provider.of<FinanceProvider>(
      context,
      listen: false,
    );
    _incomeController.text = financeProvider.budget.monthlyIncome.toString();
    _limitController.text = financeProvider.budget.spendingLimit.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Budget Settings
          _buildSectionCard(
            title: 'Budget Settings',
            icon: Icons.account_balance_wallet,
            children: [
              Consumer<FinanceProvider>(
                builder: (context, financeProvider, child) {
                  return Column(
                    children: [
                      // Monthly Income
                      TextFormField(
                        controller: _incomeController,
                        enabled: _isEditing,
                        decoration: InputDecoration(
                          labelText: l10n.monthlyIncome,
                          prefixIcon: const Icon(Icons.trending_up),
                          suffixText: Currency.getSymbol(
                            financeProvider.budget.currency,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Spending Limit
                      TextFormField(
                        controller: _limitController,
                        enabled: _isEditing,
                        decoration: InputDecoration(
                          labelText: l10n.spendingLimit,
                          prefixIcon: const Icon(Icons.warning),
                          suffixText: Currency.getSymbol(
                            financeProvider.budget.currency,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Edit/Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_isEditing) {
                              _saveBudget();
                            } else {
                              setState(() => _isEditing = true);
                            }
                          },
                          child: Text(_isEditing ? l10n.save : l10n.edit),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Appearance Settings
          _buildSectionCard(
            title: 'Appearance',
            icon: Icons.palette,
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return SwitchListTile(
                    title: Text(l10n.darkMode),
                    subtitle: const Text('Switch between light and dark theme'),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.setTheme(value),
                    secondary: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Language & Currency Settings
          _buildSectionCard(
            title: 'Localization',
            icon: Icons.language,
            children: [
              // Language Selection
              Consumer<LocaleProvider>(
                builder: (context, localeProvider, child) {
                  return ListTile(
                    title: Text(l10n.language),
                    subtitle: Text(
                      localeProvider.locale.languageCode == 'en'
                          ? l10n.english
                          : l10n.persian,
                    ),
                    leading: const Icon(Icons.language),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageDialog(),
                  );
                },
              ),
              const Divider(),
              // Currency Selection
              Consumer<FinanceProvider>(
                builder: (context, financeProvider, child) {
                  return ListTile(
                    title: Text(l10n.currency),
                    subtitle: Text(
                      _getCurrencyName(l10n, financeProvider.budget.currency),
                    ),
                    leading: const Icon(Icons.monetization_on),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showCurrencyDialog(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Data Management
          _buildSectionCard(
            title: 'Data Management',
            icon: Icons.storage,
            children: [
              ListTile(
                title: Text(l10n.exportToPdf),
                subtitle: const Text('Export your transactions to PDF'),
                leading: const Icon(Icons.picture_as_pdf),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _exportToPdf(),
              ),
              const Divider(),
              ListTile(
                title: Text(l10n.exportToCsv),
                subtitle: const Text('Export your transactions to CSV'),
                leading: const Icon(Icons.table_chart),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _exportToCsv(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // About Section
          _buildSectionCard(
            title: 'About',
            icon: Icons.info,
            children: [
              ListTile(
                title: Text(l10n.appTitle),
                subtitle: const Text('Version 1.0.0'),
                leading: const Icon(Icons.apps),
              ),
              const Divider(),
              const ListTile(
                title: Text('Developer'),
                subtitle: Text('Built with Flutter'),
                leading: Icon(Icons.code),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.english),
              onTap: () {
                Provider.of<LocaleProvider>(
                  context,
                  listen: false,
                ).setLocale(const Locale('en'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(l10n.persian),
              onTap: () {
                Provider.of<LocaleProvider>(
                  context,
                  listen: false,
                ).setLocale(const Locale('fa'));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.currency),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Currency.currencies.map((currency) {
            return ListTile(
              title: Text(_getCurrencyName(l10n, currency)),
              subtitle: Text(Currency.getSymbol(currency)),
              onTap: () async {
                final financeProvider = Provider.of<FinanceProvider>(
                  context,
                  listen: false,
                );
                final updatedBudget = financeProvider.budget.copyWith(
                  currency: currency,
                );
                await financeProvider.updateBudget(updatedBudget);
                if (mounted) Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getCurrencyName(AppLocalizations l10n, String currency) {
    switch (currency) {
      case 'rial':
        return l10n.rial;
      case 'toman':
        return l10n.toman;
      case 'usd':
        return l10n.usd;
      default:
        return currency;
    }
  }

  Future<void> _saveBudget() async {
    try {
      final income = double.tryParse(_incomeController.text) ?? 0.0;
      final limit = double.tryParse(_limitController.text) ?? 0.0;

      final financeProvider = Provider.of<FinanceProvider>(
        context,
        listen: false,
      );
      final updatedBudget = financeProvider.budget.copyWith(
        monthlyIncome: income,
        spendingLimit: limit,
      );

      await financeProvider.updateBudget(updatedBudget);

      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget settings saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving budget: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _exportToPdf() {
    // TODO: Implement PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF export feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _exportToCsv() {
    // TODO: Implement CSV export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV export feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

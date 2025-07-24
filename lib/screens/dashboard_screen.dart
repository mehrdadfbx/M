import 'package:finance/models/budget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance/providers/finance_provider.dart';
import 'package:finance/widgets/summary_card.dart';
import 'package:finance/widgets/transaction_item.dart';
import 'package:finance/models/category.dart';
import 'package:finance/l10n/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    return Scaffold(
      body: Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          final monthlyIncome = financeProvider.getMonthlyIncome(
            now.year,
            now.month,
          );
          final monthlyExpenses = financeProvider.getMonthlyExpenses(
            now.year,
            now.month,
          );
          final remainingBudget = financeProvider.getRemainingBudget(
            now.year,
            now.month,
          );
          final recentTransactions = financeProvider
              .getThisMonthTransactions()
              .take(5)
              .toList();
          final currency = financeProvider.budget.currency;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: l10n.totalIncome,
                        amount: monthlyIncome,
                        icon: Icons.trending_up,
                        color: Colors.green,
                        currency: currency,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SummaryCard(
                        title: l10n.totalExpenses,
                        amount: monthlyExpenses,
                        icon: Icons.trending_down,
                        color: Colors.red,
                        currency: currency,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SummaryCard(
                  title: l10n.remainingBudget,
                  amount: remainingBudget,
                  icon: Icons.account_balance_wallet,
                  color: remainingBudget >= 0 ? Colors.blue : Colors.orange,
                  currency: currency,
                ),
                const SizedBox(height: 24),

                // Spending Progress
                if (financeProvider.budget.spendingLimit > 0) ...[
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.track_changes,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.spendingLimit,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value:
                                monthlyExpenses /
                                financeProvider.budget.spendingLimit,
                            backgroundColor: Colors.grey.withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              monthlyExpenses >=
                                      financeProvider.budget.spendingLimit
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(monthlyExpenses / financeProvider.budget.spendingLimit * 100).toStringAsFixed(0)}% ${l10n.thisMonth.toLowerCase()}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${financeProvider.budget.spendingLimit.toStringAsFixed(0)} ${Currency.getSymbol(currency)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Pie Chart
                if (monthlyExpenses > 0) ...[
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pie_chart,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.pieChart,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: _buildPieChart(
                              financeProvider.getCategoryExpenses(
                                now.year,
                                now.month,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Recent Transactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (recentTransactions.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          // Navigate to transactions screen
                        },
                        child: Text(l10n.transactions),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (recentTransactions.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noTransactions,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.addFirstTransaction,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  ...recentTransactions.map(
                    (transaction) => TransactionItem(
                      transaction: transaction,
                      currency: currency,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> categoryExpenses) {
    if (categoryExpenses.isEmpty) {
      return const Center(child: Text('No expenses to show'));
    }

    final total = categoryExpenses.values.fold(
      0.0,
      (sum, value) => sum + value,
    );
    final sections = categoryExpenses.entries.map((entry) {
      final category = Categories.getCategoryByName(entry.key);
      final percentage = (entry.value / total * 100);

      return PieChartSectionData(
        color: category.color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(sections: sections, centerSpaceRadius: 40, sectionsSpace: 2),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance/providers/finance_provider.dart';
import 'package:finance/models/category.dart';
import 'package:finance/models/budget.dart';
import 'package:finance/l10n/app_localizations.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMonthOffset = 0; // 0 = current month, 1 = last month, etc.

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final selectedDate = DateTime(now.year, now.month - _selectedMonthOffset);

    return Column(
      children: [
        // Month Selector
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() => _selectedMonthOffset++);
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _selectedMonthOffset > 0
                    ? () {
                        setState(() => _selectedMonthOffset--);
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),

        // Tabs
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.pieChart),
            Tab(text: l10n.barChart),
            Tab(text: l10n.candlestickChart),
          ],
        ),

        // Tab Content
        Expanded(
          child: Consumer<FinanceProvider>(
            builder: (context, financeProvider, child) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildPieChart(financeProvider, selectedDate),
                  _buildBarChart(financeProvider, selectedDate),
                  _buildCandlestickChart(financeProvider, selectedDate),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(
    FinanceProvider financeProvider,
    DateTime selectedDate,
  ) {
    final categoryExpenses = financeProvider.getCategoryExpenses(
      selectedDate.year,
      selectedDate.month,
    );
    final currency = financeProvider.budget.currency;

    if (categoryExpenses.isEmpty) {
      return _buildEmptyState('No expenses to show for this month');
    }

    final total = categoryExpenses.values.fold(
      0.0,
      (sum, value) => sum + value,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: categoryExpenses.entries.map((entry) {
                  final category = Categories.getCategoryByName(entry.key);
                  final percentage = (entry.value / total * 100);

                  return PieChartSectionData(
                    color: category.color,
                    value: entry.value,
                    title: '${percentage.toStringAsFixed(1)}%',
                    radius: 100,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 60,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          ...categoryExpenses.entries.map((entry) {
            final category = Categories.getCategoryByName(entry.key);
            final percentage = (entry.value / total * 100);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: category.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(category.icon, size: 20, color: category.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '${entry.value.toStringAsFixed(0)} ${Currency.getSymbol(currency)} (${percentage.toStringAsFixed(1)}%)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBarChart(
    FinanceProvider financeProvider,
    DateTime selectedDate,
  ) {
    final income = financeProvider.getMonthlyIncome(
      selectedDate.year,
      selectedDate.month,
    );
    final expenses = financeProvider.getMonthlyExpenses(
      selectedDate.year,
      selectedDate.month,
    );
    final currency = financeProvider.budget.currency;

    if (income == 0 && expenses == 0) {
      return _buildEmptyState('No financial data to show for this month');
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: [income, expenses].reduce((a, b) => a > b ? a : b) * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Income');
                          case 1:
                            return const Text('Expenses');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          _formatAmount(value),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: income,
                        color: Colors.green,
                        width: 40,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: expenses,
                        color: Colors.red,
                        width: 40,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Income', income, Colors.green, currency),
              _buildSummaryItem('Expenses', expenses, Colors.red, currency),
              _buildSummaryItem(
                'Net',
                income - expenses,
                income >= expenses ? Colors.green : Colors.red,
                currency,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCandlestickChart(
    FinanceProvider financeProvider,
    DateTime selectedDate,
  ) {
    // For demonstration, we'll show a simple line chart of daily expenses
    final transactions = financeProvider.transactions
        .where(
          (t) =>
              t.date.year == selectedDate.year &&
              t.date.month == selectedDate.month &&
              !t.isIncome,
        )
        .toList();

    if (transactions.isEmpty) {
      return _buildEmptyState('No expense data to show for this month');
    }

    // Group transactions by day
    Map<int, double> dailyExpenses = {};
    for (var transaction in transactions) {
      final day = transaction.date.day;
      dailyExpenses[day] = (dailyExpenses[day] ?? 0) + transaction.amount;
    }

    final spots = dailyExpenses.entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    spots.sort((a, b) => a.x.compareTo(b.x));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    _formatAmount(value),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    double amount,
    Color color,
    String currency,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          '${_formatAmount(amount)} ${Currency.getSymbol(currency)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}

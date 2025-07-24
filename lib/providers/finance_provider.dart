import 'package:flutter/material.dart';
import 'package:finance/models/transaction.dart';
import 'package:finance/models/budget.dart';
import 'package:finance/services/database_service.dart';
import 'package:finance/services/preferences_service.dart';

class FinanceProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  BudgetModel _budget = BudgetModel(
    monthlyIncome: 0,
    spendingLimit: 0,
    currency: 'toman',
  );
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  BudgetModel get budget => _budget;
  bool get isLoading => _isLoading;

  FinanceProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await DatabaseService.getTransactions();
      _budget = await PreferencesService.getBudget();

      // Add sample data if no transactions exist
      if (_transactions.isEmpty) {
        await _addSampleData();
        _transactions = await DatabaseService.getTransactions();
      }

      // Set default budget if not set
      if (_budget.monthlyIncome == 0 && _budget.spendingLimit == 0) {
        _budget = BudgetModel(
          monthlyIncome: 5000000,
          spendingLimit: 3000000,
          currency: 'toman',
        );
        await PreferencesService.setBudget(_budget);
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _addSampleData() async {
    final now = DateTime.now();
    final sampleTransactions = [
      TransactionModel(
        amount: 5000000,
        category: 'income',
        description: 'Monthly Salary',
        date: DateTime(now.year, now.month, 1),
        isIncome: true,
      ),
      TransactionModel(
        amount: 250000,
        category: 'food',
        description: 'Grocery shopping',
        date: DateTime(now.year, now.month, 3),
        isIncome: false,
      ),
      TransactionModel(
        amount: 150000,
        category: 'transport',
        description: 'Gas for car',
        date: DateTime(now.year, now.month, 5),
        isIncome: false,
      ),
      TransactionModel(
        amount: 80000,
        category: 'entertainment',
        description: 'Movie tickets',
        date: DateTime(now.year, now.month, 8),
        isIncome: false,
      ),
      TransactionModel(
        amount: 300000,
        category: 'shopping',
        description: 'Clothing',
        date: DateTime(now.year, now.month, 12),
        isIncome: false,
      ),
      TransactionModel(
        amount: 120000,
        category: 'health',
        description: 'Doctor visit',
        date: DateTime(now.year, now.month, 15),
        isIncome: false,
      ),
      TransactionModel(
        amount: 200000,
        category: 'bills',
        description: 'Electricity bill',
        date: DateTime(now.year, now.month, 18),
        isIncome: false,
      ),
    ];

    for (var transaction in sampleTransactions) {
      await DatabaseService.insertTransaction(transaction);
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final id = await DatabaseService.insertTransaction(transaction);
      final newTransaction = transaction.copyWith(id: id);
      _transactions.insert(0, newTransaction);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await DatabaseService.updateTransaction(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await DatabaseService.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  Future<void> updateBudget(BudgetModel budget) async {
    try {
      await PreferencesService.setBudget(budget);
      _budget = budget;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating budget: $e');
    }
  }

  // Monthly calculations
  double getMonthlyIncome(int year, int month) {
    final monthlyTransactions = _transactions.where(
      (t) => t.date.year == year && t.date.month == month && t.isIncome,
    );
    return monthlyTransactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  double getMonthlyExpenses(int year, int month) {
    final monthlyTransactions = _transactions.where(
      (t) => t.date.year == year && t.date.month == month && !t.isIncome,
    );
    return monthlyTransactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  double getRemainingBudget(int year, int month) {
    final expenses = getMonthlyExpenses(year, month);
    return _budget.spendingLimit - expenses;
  }

  Map<String, double> getCategoryExpenses(int year, int month) {
    final monthlyExpenses = _transactions.where(
      (t) => t.date.year == year && t.date.month == month && !t.isIncome,
    );

    Map<String, double> categoryTotals = {};
    for (var transaction in monthlyExpenses) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
    return categoryTotals;
  }

  bool isSpendingLimitReached(int year, int month) {
    return getMonthlyExpenses(year, month) >= _budget.spendingLimit;
  }

  List<TransactionModel> getThisMonthTransactions() {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();
  }
}

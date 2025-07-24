import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:finance/models/transaction.dart';

class DatabaseService {
  static Database? _database;
  static const String _transactionsTable = 'transactions';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pocketsage.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_transactionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        isIncome INTEGER NOT NULL
      )
    ''');
  }

  static Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert(_transactionsTable, transaction.toMap());
  }

  static Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final maps = await db.query(_transactionsTable, orderBy: 'date DESC');
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  static Future<List<TransactionModel>> getTransactionsByMonth(
    int year,
    int month,
  ) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final maps = await db.query(
      _transactionsTable,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  static Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      _transactionsTable,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  static Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      _transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<double> getTotalIncome(int year, int month) async {
    final transactions = await getTransactionsByMonth(year, month);
    return transactions
        .where((t) => t.isIncome)
        // ignore: unnecessary_type_check
        .fold<double>(
          0.0,
          (sum, t) =>
              sum +
              // ignore: unnecessary_type_check
              (t.amount is double ? t.amount : (t.amount as num).toDouble()),
        );
  }

  static Future<double> getTotalExpenses(int year, int month) async {
    final transactions = await getTransactionsByMonth(year, month);
    return transactions
        .where((t) => !t.isIncome)
        // ignore: unnecessary_type_check
        .fold<double>(
          0.0,
          (sum, t) =>
              sum +
              // ignore: unnecessary_type_check
              (t.amount is double ? t.amount : (t.amount as num).toDouble()),
        );
  }

  static Future<Map<String, double>> getExpensesByCategory(
    int year,
    int month,
  ) async {
    final transactions = await getTransactionsByMonth(year, month);
    final expenses = transactions.where((t) => !t.isIncome);

    Map<String, double> categoryTotals = {};
    for (var transaction in expenses) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
    return categoryTotals;
  }
}

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/expense.dart';
import '../../models/category.dart';
import '../../models/budget_cycle.dart';
import '../../models/user.dart';
import 'i_finance_repository.dart';

class SqliteFinanceRepository implements IFinanceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<void> addCategory(Category category) async {
    final db = await _dbHelper.database;
    await db.insert('Category', category.toMap());
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final db = await _dbHelper.database;
    await db.insert('Expense', expense.toMap());
  }

  @override
  Future<void> createBudgetCycle(BudgetCycle cycle) async {
    final db = await _dbHelper.database;
    await db.insert('BudgetCycle', cycle.toMap());
  }

  @override
  Future<void> deleteExpense(int id) async {
    final db = await _dbHelper.database;
    await db.delete('Expense', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Category>> getCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query('Category');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  @override
  Future<BudgetCycle?> getCurrentBudgetCycle() async {
    final db = await _dbHelper.database;
    final maps = await db.query('BudgetCycle', orderBy: 'id DESC', limit: 1);
    if (maps.isNotEmpty) {
      return BudgetCycle.fromMap(maps.first);
    }
    return null; 
  }

  @override
  Future<List<Expense>> getExpenses({DateTime? startDate, DateTime? endDate}) async {
    final db = await _dbHelper.database;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (startDate != null && endDate != null) {
      whereClause = 'date >= ? AND date <= ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }

    final maps = await db.query(
      'Expense', 
      where: whereClause, 
      whereArgs: whereArgs, 
      orderBy: 'date DESC'
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  @override
  Future<Map<int, double>> getExpensesByCategory({DateTime? startDate, DateTime? endDate}) async {
    final db = await _dbHelper.database;
    String where = '';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      where = 'WHERE date >= ? AND date <= ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }

    final result = await db.rawQuery(
      'SELECT categoryId, SUM(amount) as total FROM Expense $where GROUP BY categoryId',
      whereArgs.isEmpty ? null : whereArgs,
    );

    Map<int, double> expensesByCategory = {};
    for (var row in result) {
      expensesByCategory[row['categoryId'] as int] = (row['total'] as num).toDouble();
    }
    return expensesByCategory;
  }

  @override
  Future<double> getTotalExpenses({DateTime? startDate, DateTime? endDate}) async {
    final db = await _dbHelper.database;
    String where = '';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      where = 'WHERE date >= ? AND date <= ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM Expense $where',
      whereArgs.isEmpty ? null : whereArgs,
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final db = await _dbHelper.database;
    await db.update(
      'Expense',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }
}

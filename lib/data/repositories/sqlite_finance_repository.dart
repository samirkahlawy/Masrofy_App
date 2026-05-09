import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/expense.dart';
import '../../models/category.dart';
import '../../models/budget_cycle.dart';
import '../../models/user.dart';
import 'i_finance_repository.dart';

/// An implementation of [IFinanceRepository] using [SharedPreferences] for local storage.
/// 
/// Note: Despite the class name, this currently persists data as JSON strings 
/// within Shared Preferences rather than a SQLite database.
class SqliteFinanceRepository implements IFinanceRepository {
  static const String _categoriesKey = 'categories';
  static const String _expensesKey = 'expenses';
  static const String _budgetCycleKey = 'budget_cycle';
  static const String _userKey = 'user';

  /// Helper to get the [SharedPreferences] instance.
  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  /// Internal helper to load and decode categories from local storage.
  Future<List<Category>> _loadCategories() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_categoriesKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Category.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> _saveCategories(List<Category> categories) async {
    final prefs = await _prefs;
    await prefs.setString(
      _categoriesKey,
      jsonEncode(categories.map((e) => e.toMap()).toList()),
    );
  }

  /// Internal helper to load and decode expenses from local storage.
  Future<List<Expense>> _loadExpenses() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_expensesKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Expense.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  /// Internal helper to encode and save expenses to local storage.
  Future<void> _saveExpenses(List<Expense> expenses) async {
    final prefs = await _prefs;
    await prefs.setString(
      _expensesKey,
      jsonEncode(expenses.map((e) => e.toMap()).toList()),
    );
  }

  @override
  Future<void> addCategory(Category category) async {
    final categories = await _loadCategories();
    final nextId = categories.map((c) => c.id ?? 0).fold(0, max) + 1;
    final newCategory = category.copyWith(id: nextId);
    categories.add(newCategory);
    await _saveCategories(categories);
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final expenses = await _loadExpenses();
    final nextId = expenses.map((e) => e.id ?? 0).fold(0, max) + 1;
    final newExpense = expense.copyWith(id: nextId);
    expenses.add(newExpense);
    await _saveExpenses(expenses);
  }

  @override
  Future<void> createBudgetCycle(BudgetCycle cycle) async {
    final prefs = await _prefs;
    await prefs.setString(_budgetCycleKey, jsonEncode(cycle.toMap()));
  }

  @override
  Future<void> deleteExpense(int id) async {
    final expenses = await _loadExpenses();
    final updated = expenses.where((expense) => expense.id != id).toList();
    await _saveExpenses(updated);
  }

  @override
  Future<List<Category>> getCategories() async {
    return _loadCategories();
  }

  @override
  Future<BudgetCycle?> getCurrentBudgetCycle() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_budgetCycleKey);
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final cycle = BudgetCycle.fromMap(Map<String, dynamic>.from(decoded));
    return cycle.isExpired() ? null : cycle;
  }

  @override
  Future<List<Expense>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var expenses = await _loadExpenses();
    if (startDate != null) {
      expenses = expenses
          .where((expense) => !expense.date.isBefore(startDate))
          .toList();
    }
    if (endDate != null) {
      expenses = expenses
          .where((expense) => !expense.date.isAfter(endDate))
          .toList();
    }
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  @override
  Future<Map<int, double>> getExpensesByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final expenses = await getExpenses(startDate: startDate, endDate: endDate);
    final totals = <int, double>{};
    for (final expense in expenses) {
      final categoryId = expense.categoryId;
      if (categoryId == null) continue;
      totals[categoryId] = (totals[categoryId] ?? 0) + expense.amount;
    }
    return totals;
  }

  @override
  Future<double> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final expenses = await getExpenses(startDate: startDate, endDate: endDate);
    return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final expenses = await _loadExpenses();
    final index = expenses.indexWhere((element) => element.id == expense.id);
    if (index < 0) return;
    expenses[index] = expense;
    await _saveExpenses(expenses);
  }

  @override
  Future<BudgetCycle?> getActiveCycle() async {
    return getCurrentBudgetCycle();
  }

  @override
  Future<void> saveCycle(BudgetCycle cycle) async {
    return createBudgetCycle(cycle);
  }

  @override
  Future<User?> getUser() async {
    developer.log('LocalStorageRepo: getUser called', name: 'LocalStorageRepo');
    final prefs = await _prefs;
    final raw = prefs.getString(_userKey);
    developer.log(
      'LocalStorageRepo: raw user data=$raw',
      name: 'LocalStorageRepo',
    );
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final user = User.fromMap(Map<String, dynamic>.from(decoded));
    developer.log(
      'LocalStorageRepo: parsed user=${user.toMap()}',
      name: 'LocalStorageRepo',
    );
    return user;
  }

  @override
  Future<void> saveUser(User user) async {
    developer.log(
      'LocalStorageRepo: saveUser called with user=${user.toMap()}',
      name: 'LocalStorageRepo',
    );
    final prefs = await _prefs;
    final json = jsonEncode(user.toMap());
    developer.log(
      'LocalStorageRepo: saving json=$json',
      name: 'LocalStorageRepo',
    );
    await prefs.setString(_userKey, json);
    developer.log(
      'LocalStorageRepo: user saved to key=$_userKey',
      name: 'LocalStorageRepo',
    );
  }
}

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/i_finance_repository.dart';
import '../data/repositories/sqlite_finance_repository.dart';
import '../logic/finance_calculator_service.dart';
import '../models/budget_cycle.dart';
import '../models/category.dart';
import '../models/expense.dart';

/// A comprehensive provider that orchestrates high-level finance data, 
/// including categories, current cycles, and calculated metrics.
class FinanceProvider extends ChangeNotifier {
  /// The underlying data source.
  final IFinanceRepository repo;
  
  /// The service used for financial math.
  final FinanceCalculatorService calculator;

  BudgetCycle? currentCycle;
  List<Expense> expenses = [];
  List<Category> categories = [];
  double safeDailyLimit = 0;
  bool isLimitReached = false;
  bool isLoading = true;
  double totalExpenses = 0;
  Map<int, double> expensesByCategory = {};

  FinanceProvider({IFinanceRepository? repository})
    : repo = repository ?? SqliteFinanceRepository(),
      calculator = FinanceCalculatorService();

  /// Loads categories, the current cycle, and calculates spending summaries.
  Future<void> loadInitialData() async {
    isLoading = true;
    notifyListeners();

    categories = await repo.getCategories();
    if (categories.isEmpty) {
      await _saveDefaultCategories();
      categories = await repo.getCategories();
    }

    currentCycle = await repo.getCurrentBudgetCycle();
    if (currentCycle != null) {
      expenses = await repo.getExpenses(
        startDate: currentCycle!.startDate,
        endDate: currentCycle!.endDate,
      );
      totalExpenses = await repo.getTotalExpenses(
        startDate: currentCycle!.startDate,
        endDate: currentCycle!.endDate,
      );
      expensesByCategory = await repo.getExpensesByCategory(
        startDate: currentCycle!.startDate,
        endDate: currentCycle!.endDate,
      );
      final todayExpenses = _getTodayExpenses();
      safeDailyLimit = calculator.calculateSafeDailyLimit(
        currentCycle!,
        todayExpenses,
      );
      isLimitReached = totalExpenses > safeDailyLimit;
    } else {
      expenses = [];
      totalExpenses = 0;
      expensesByCategory = {};
      safeDailyLimit = 0;
      isLimitReached = false;
    }

    isLoading = false;
    notifyListeners();
  }

  /// Populates the database with default categories if they don't exist.
  Future<void> _saveDefaultCategories() async {
    final defaultCategories = [
      Category(name: 'طعام', iconPath: null),
      Category(name: 'مشروبات', iconPath: null),
      Category(name: 'سفر', iconPath: null),
      Category(name: 'ترفيه', iconPath: null),
      Category(name: 'تسوق', iconPath: null),
    ];

    for (final category in defaultCategories) {
      await repo.addCategory(category);
    }
  }

  /// Creates a new [BudgetCycle] and reloads data.
  Future<void> createBudgetCycle(double totalAllowance) async {
    final cycle = BudgetCycle(
      userId: 1,
      totalAllowance: totalAllowance,
      remainingBalance: totalAllowance,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      expenses: [],
    );
    await repo.createBudgetCycle(cycle);
    await loadInitialData();
  }

  /// Adds a new expense and refreshes all metrics.
  Future<void> addNewExpense(double amount, String note, int categoryId) async {
    if (currentCycle == null) return;
    final expense = Expense(
      amount: amount,
      note: note,
      date: DateTime.now(),
      categoryId: categoryId,
      userId: 1,
    );
    await repo.addExpense(expense);
    await loadInitialData();
  }

  /// Deletes an expense and refreshes metrics.
  Future<void> deleteExpense(int id) async {
    await repo.deleteExpense(id);
    await loadInitialData();
  }

  /// Filters [expenses] to return only those recorded today.
  List<Expense> _getTodayExpenses() {
    final now = DateTime.now();
    return expenses.where((e) {
      return e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day;
    }).toList();
  }

  /// Recalculates UI state values like [safeDailyLimit] and [totalExpenses].
  void updateUIState() {
    totalExpenses = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final todayExpenses = _getTodayExpenses();
    safeDailyLimit = currentCycle != null
        ? calculator.calculateSafeDailyLimit(currentCycle!, todayExpenses)
        : 0;
    isLimitReached = totalExpenses > safeDailyLimit;
    notifyListeners();
  }

  /// Wipes all application data from local storage.
  Future<void> resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('expenses');
    await prefs.remove('budget_cycle');
    await prefs.setBool('isFirstTime', true);
    await prefs.remove('user_pin_hash');
    currentCycle = null;
    expenses = [];
    totalExpenses = 0;
    expensesByCategory = {};
    safeDailyLimit = 0;
    isLimitReached = false;
    notifyListeners();
  }
}
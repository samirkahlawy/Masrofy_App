import '../repositories/ifinance_repository.dart';

import '../services/finance_calculator_service.dart';

import '../models/budget_cycle.dart';
import '../models/expense.dart';
import '../models/category.dart';

class FinanceProvider {

  final IFinanceRepository repo;

  final FinanceCalculatorService calculator;

  BudgetCycle? currentCycle;

  List<Expense> expenses = [];

  List<Category> categories = [];

  double safeDailyLimit = 0;

  bool isLimitReached = false;

  bool isLoading = false;

  double totalExpenses = 0;

  Map<int, double> expensesByCategory = {};

  FinanceProvider(
    this.repo,
    this.calculator,
  );

  Future<void> loadInitialData() async {

  }

  Future<void> createBudgetCycle(
    double allowance,
  ) async {

  }

  Future<void> addNewExpense(
    double amount,
    String note,
    int categoryId,
  ) async {

  }

  Future<void> deleteExpense(
    int id,
  ) async {

  }

  void updateUIState() {

  }

  Future<void> resetData() async {

  }
}
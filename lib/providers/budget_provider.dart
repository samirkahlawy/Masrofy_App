import '../repositories/ifinance_repository.dart';
import '../services/ifinance_calculator_service.dart';

import '../models/budget_cycle.dart';
import '../models/expense.dart';

class BudgetProvider {

  final IFinanceRepository _repo;

  final IFinanceCalculatorService _calc;

  BudgetCycle? _currentBudgetCycle;

  double _remainingBudget = 0;

  BudgetProvider(
    this._repo,
    this._calc,
  );

  BudgetCycle? get currentBudgetCycle =>
      _currentBudgetCycle;

  double get remainingBudget =>
      _remainingBudget;

  Future<void> init() async {

  }

  Future<void> startNewCycle(
    double amount,
    DateTime startDate,
    DateTime endDate,
  ) async {

  }

  Future<void> updateRemainingBudget(
    double amount,
  ) async {

  }

  Future<void> refresh() async {

  }

  double calculateSafeDailyLimit(
    List<Expense> todayExpenses,
  ) {
    return 0;
  }
}
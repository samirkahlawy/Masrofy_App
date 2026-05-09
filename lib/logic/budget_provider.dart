import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../data/repositories/i_finance_repository.dart';
import '../data/repositories/sqlite_finance_repository.dart';
import '../logic/finance_calculator_service.dart';
import '../logic/i_finance_calculator_service.dart';
import '../models/budget_cycle.dart';
import '../models/expense.dart';

/// Manages the state and logic of the current budget cycle and spending limits.
class BudgetProvider extends ChangeNotifier {
  final IFinanceRepository _repo;
  final IFinanceCalculatorService _calc;

  BudgetCycle? _currentBudgetCycle;
  double _remainingBudget = 0;

  /// Creates a [BudgetProvider] with optional repository and calculator services.
  BudgetProvider({IFinanceRepository? repo, IFinanceCalculatorService? calc})
    : _repo = repo ?? SqliteFinanceRepository(),
      _calc = calc ?? FinanceCalculatorService();

  /// Returns the active [BudgetCycle].
  BudgetCycle? get currentBudgetCycle => _currentBudgetCycle;
  
  /// Returns the amount left to spend in the current cycle.
  double get remainingBudget => _remainingBudget;

  /// Loads the active cycle and calculates the remaining budget based on expenses.
  Future<void> init() async {
    _currentBudgetCycle = await _repo.getActiveCycle();
    if (_currentBudgetCycle != null) {
      final expenses = await _repo.getExpenses(
        startDate: _currentBudgetCycle!.startDate,
        endDate: _currentBudgetCycle!.endDate,
      );
      final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
      _remainingBudget = _currentBudgetCycle!.totalAllowance - totalSpent;
    }
    notifyListeners();
  }

  /// Starts a new budget cycle with a specific [amount] and date range.
  Future<void> startNewCycle(
    double amount,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final cycle = BudgetCycle(
      userId: 1,
      totalAllowance: amount,
      remainingBalance: amount,
      startDate: startDate,
      endDate: endDate,
      expenses: [],
    );
    await _repo.saveCycle(cycle);
    _currentBudgetCycle = cycle;
    _remainingBudget = amount;
    notifyListeners();
  }

  /// Manually updates the [remainingBudget] state.
  Future<void> updateRemainingBudget(double amount) async {
    _remainingBudget = amount;
    notifyListeners();
  }

  /// Re-fetches budget data from the repository.
  Future<void> refresh() async {
    await init();
  }

  /// Calculates how much can be spent today based on the remaining budget.
  double calculateSafeDailyLimit(List<Expense> todayExpenses) {
    if (_currentBudgetCycle == null) return 0;
    return _calc.calculateSafeDailyLimit(_currentBudgetCycle!, todayExpenses);
  }
}

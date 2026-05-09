import '../models/budget_cycle.dart';
import '../models/expense.dart';
import 'i_finance_calculator_service.dart';

/// Implementation of financial logic and calculations.
class FinanceCalculatorService implements IFinanceCalculatorService {
  @override
  double calculateSafeDailyLimit(BudgetCycle cycle, List<Expense> spentToday) {
    final dailyLimit = cycle.calculateDailyLimit();
    final todayTotal = spentToday.fold(0.0, (sum, e) => sum + e.amount);
    return dailyLimit - todayTotal;
  }

  @override
  double calculateRollover(double spentToday, double dailyLimit) {
    final rollover = dailyLimit - spentToday;
    return rollover > 0 ? rollover : 0;
  }

  @override
  bool checkThreshold(double totalSpent, double limit) {
    return totalSpent >= limit * 0.75;
  }

  @override
  Map<String, double> calculateCategoryPercentages(List<Expense> expenses) {
    final totals = <String, double>{};
    var totalAmount = 0.0;

    for (final expense in expenses) {
      final categoryKey = expense.categoryId?.toString() ?? 'unknown';
      totals[categoryKey] = (totals[categoryKey] ?? 0) + expense.amount;
      totalAmount += expense.amount;
    }

    if (totalAmount == 0) return {};

    return totals.map(
      (categoryId, amount) =>
          MapEntry(categoryId, (amount / totalAmount) * 100),
    );
  }
}

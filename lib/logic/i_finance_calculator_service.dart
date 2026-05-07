import '../models/budget_cycle.dart';
import '../models/expense.dart';

/// Interface defining the required logic for budget and expense calculations.
abstract class IFinanceCalculatorService {
  /// Calculates how much money is safe to spend today.
  double calculateSafeDailyLimit(BudgetCycle cycle, List<Expense> spentToday);

  /// Calculates the amount that can be rolled over to the next day.
  double calculateRollover(double spentToday, double dailyLimit);

  /// Checks if the spending has reached a certain percentage of the limit.
  bool checkThreshold(double totalSpent, double limit);

  /// Calculates the percentage of total spending allocated to each category.
  Map<String, double> calculateCategoryPercentages(List<Expense> expenses);
}
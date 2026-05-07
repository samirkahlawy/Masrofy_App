import '../models/budget_cycle.dart';
import '../models/expense.dart';

abstract class IFinanceCalculatorService {
  double calculateSafeDailyLimit(BudgetCycle cycle, List<Expense> spentToday);
  double calculateRollover(double spentToday, double dailyLimit);
  bool checkThreshold(double totalSpent, double limit);
  Map<String, double> calculateCategoryPercentages(List<Expense> expenses);
}

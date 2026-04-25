import '../../models/expense.dart';
import '../../models/category.dart';
import '../../models/budget_cycle.dart';

abstract class IFinanceRepository {
  Future<List<Expense>> getExpenses({DateTime? startDate, DateTime? endDate});
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(int id);
  Future<List<Category>> getCategories();
  Future<void> addCategory(Category category);
  Future<BudgetCycle?> getCurrentBudgetCycle();
  Future<void> createBudgetCycle(BudgetCycle cycle);
  Future<double> getTotalExpenses({DateTime? startDate, DateTime? endDate});
  Future<Map<int, double>> getExpensesByCategory({
    DateTime? startDate,
    DateTime? endDate,
  });
}

import '../../models/expense.dart';
import '../../models/category.dart';
import '../../models/budget_cycle.dart';
import '../../models/user.dart';

abstract class IFinanceRepository {
  Future<BudgetCycle?> getActiveCycle();
  Future<void> saveCycle(BudgetCycle cycle);
  Future<void> addExpense(Expense expense);
  Future<List<Expense>> getExpenses({DateTime? startDate, DateTime? endDate});
  Future<void> deleteExpense(int id);
  Future<User?> getUser();
  Future<void> saveUser(User user);
  Future<List<Category>> getCategories();
  Future<void> addCategory(Category category);
  Future<double> getTotalExpenses({DateTime? startDate, DateTime? endDate});
  Future<Map<int, double>> getExpensesByCategory({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Legacy methods for compatibility
  Future<BudgetCycle?> getCurrentBudgetCycle();
  Future<void> createBudgetCycle(BudgetCycle cycle);
  Future<void> updateExpense(Expense expense);
}

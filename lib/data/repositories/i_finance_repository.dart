import '../../models/expense.dart';
import '../../models/category.dart';
import '../../models/budget_cycle.dart';
import '../../models/user.dart';

/// An abstract interface defining the contract for financial data persistence.
abstract class IFinanceRepository {
  /// Retrieves the currently active [BudgetCycle], if any.
  Future<BudgetCycle?> getActiveCycle();

  /// Persists a [BudgetCycle] to storage.
  Future<void> saveCycle(BudgetCycle cycle);

  /// Records a new [Expense] in the system.
  Future<void> addExpense(Expense expense);

  /// Retrieves a list of [Expense] items, optionally filtered by a date range.
  Future<List<Expense>> getExpenses({DateTime? startDate, DateTime? endDate});

  /// Removes an [Expense] from storage by its unique [id].
  Future<void> deleteExpense(int id);

  /// Retrieves the stored [User] profile information.
  Future<User?> getUser();

  /// Persists [User] profile information.
  Future<void> saveUser(User user);

  /// Retrieves all available expense [Category] items.
  Future<List<Category>> getCategories();

  /// Adds a new [Category] to the system.
  Future<void> addCategory(Category category);

  /// Calculates the sum of all expenses within an optional date range.
  Future<double> getTotalExpenses({DateTime? startDate, DateTime? endDate});

  /// Calculates total spending grouped by category ID.
  /// 
  /// Returns a [Map] where keys are category IDs and values are total amounts.
  Future<Map<int, double>> getExpensesByCategory({
    DateTime? startDate,
    DateTime? endDate,
  });

  // --- Legacy methods for compatibility ---

  /// Alias for [getActiveCycle].
  Future<BudgetCycle?> getCurrentBudgetCycle();

  /// Alias for [saveCycle].
  Future<void> createBudgetCycle(BudgetCycle cycle);

  /// Updates an existing [Expense] record.
  Future<void> updateExpense(Expense expense);
}
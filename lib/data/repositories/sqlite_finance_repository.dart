import '../local/database_helper.dart';
import '../../models/expense.dart';
import '../../models/category.dart';
import '../../models/budget_cycle.dart';
import 'i_finance_repository.dart';

class SqliteFinanceRepository implements IFinanceRepository {
  @override
  Future<void> addCategory(Category category) {
    // TODO: implement addCategory
    throw UnimplementedError();
  }

  @override
  Future<void> addExpense(Expense expense) {
    // TODO: implement addExpense
    throw UnimplementedError();
  }

  @override
  Future<void> createBudgetCycle(BudgetCycle cycle) {
    // TODO: implement createBudgetCycle
    throw UnimplementedError();
  }

  @override
  Future<void> deleteExpense(int id) {
    // TODO: implement deleteExpense
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> getCategories() {
    // TODO: implement getCategories
    throw UnimplementedError();
  }

  @override
  Future<BudgetCycle?> getCurrentBudgetCycle() {
    // TODO: implement getCurrentBudgetCycle
    throw UnimplementedError();
  }

  @override
  Future<List<Expense>> getExpenses({DateTime? startDate, DateTime? endDate}) {
    // TODO: implement getExpenses
    throw UnimplementedError();
  }

  @override
  Future<Map<int, double>> getExpensesByCategory({DateTime? startDate, DateTime? endDate}) {
    // TODO: implement getExpensesByCategory
    throw UnimplementedError();
  }

  @override
  Future<double> getTotalExpenses({DateTime? startDate, DateTime? endDate}) {
    // TODO: implement getTotalExpenses
    throw UnimplementedError();
  }

  @override
  Future<void> updateExpense(Expense expense) {
    // TODO: implement updateExpense
    throw UnimplementedError();
  }
  
}

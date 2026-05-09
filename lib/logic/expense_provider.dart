import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../data/repositories/i_finance_repository.dart';
import '../data/repositories/sqlite_finance_repository.dart';
import '../models/expense.dart';

/// Manages the collection of expenses, including pagination and CRUD operations.
class ExpenseProvider extends ChangeNotifier {
  final IFinanceRepository _repo;

  List<Expense> _expenses = [];
  bool _isLoading = false;
  int _currentPage = 0;
  static const int _pageSize = 20;

  /// Creates an [ExpenseProvider] with an optional [IFinanceRepository].
  ExpenseProvider({IFinanceRepository? repo})
    : _repo = repo ?? SqliteFinanceRepository();

  /// The list of loaded expenses.
  List<Expense> get expenses => _expenses;

  /// Indicates if a data operation is currently in progress.
  bool get isLoading => _isLoading;

  /// The current page index for pagination.
  int get currentPage => _currentPage;

  /// Fetches the initial set of expenses
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _expenses = await _repo.getExpenses();
    _currentPage = 0;

    _isLoading = false;
    notifyListeners();
  }

  /// Loads the next set of expenses based on [_pageSize].
  Future<void> loadMore() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    _currentPage++;
    final allExpenses = await _repo.getExpenses();
    final startIndex = _currentPage * _pageSize;
    final endIndex = startIndex + _pageSize;

    if (startIndex < allExpenses.length) {
      final newExpenses = allExpenses.sublist(
        startIndex,
        endIndex > allExpenses.length ? allExpenses.length : endIndex,
      );
      _expenses.addAll(newExpenses);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Adds a new [expense] and refreshes the list.
  Future<void> addExpense(Expense expense) async {
    await _repo.addExpense(expense);
    await init();
  }

  /// Deletes an expense by its [id] and updates the local state.
  Future<void> deleteExpense(int id) async {
    await _repo.deleteExpense(id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// Overwrites the current list of expenses and notifies listeners.
  void setExpenses(List<Expense> expenses) {
    _expenses = expenses;
    notifyListeners();
  }
}

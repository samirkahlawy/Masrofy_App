import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../data/repositories/i_finance_repository.dart';
import '../data/repositories/sqlite_finance_repository.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final IFinanceRepository _repo;

  List<Expense> _expenses = [];
  bool _isLoading = false;
  int _currentPage = 0;
  static const int _pageSize = 20;

  ExpenseProvider({IFinanceRepository? repo})
    : _repo = repo ?? SqliteFinanceRepository();

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _expenses = await _repo.getExpenses();
    _currentPage = 0;

    _isLoading = false;
    notifyListeners();
  }

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

  Future<void> addExpense(Expense expense) async {
    await _repo.addExpense(expense);
    await init();
  }

  Future<void> deleteExpense(int id) async {
    await _repo.deleteExpense(id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void setExpenses(List<Expense> expenses) {
    _expenses = expenses;
    notifyListeners();
  }
}

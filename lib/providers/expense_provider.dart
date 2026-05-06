import '../repositories/ifinance_repository.dart';
import '../models/expense.dart';

class ExpenseProvider {

  final IFinanceRepository _repo;

  List<Expense> _expenses = [];

  bool _isLoading = false;

  int _currentPage = 1;

  int pageSize = 10;

  ExpenseProvider(this._repo);

  List<Expense> get expenses => _expenses;

  bool get isLoading => _isLoading;

  int get currentPage => _currentPage;

  Future<void> init() async {

  }

  Future<void> loadMore() async {

  }

  Future<void> addExpense(
    Expense expense,
  ) async {

  }

  Future<void> deleteExpense(
    int id,
  ) async {

  }

  void setExpenses(
    List<Expense> expenses,
  ) {
    _expenses = expenses;
  }
}
import 'expense.dart';

class BudgetCycle {

  int? id;

  int userId;

  double totalAllowance;

  double remainingBalance;

  DateTime startDate;

  DateTime endDate;

  List<Expense> expenses;

  BudgetCycle({
    this.id,
    required this.userId,
    required this.totalAllowance,
    required this.remainingBalance,
    required this.startDate,
    required this.endDate,
    required this.expenses,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'totalAllowance': totalAllowance,
      'remainingBalance': remainingBalance,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory BudgetCycle.fromMap(
    Map<String, dynamic> map,
  ) {
    return BudgetCycle(
      id: map['id'],
      userId: map['userId'],
      totalAllowance: map['totalAllowance'],
      remainingBalance: map['remainingBalance'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      expenses: [],
    );
  }

  bool isExpired() {
    return DateTime.now().isAfter(endDate);
  }

  double calculateDailyLimit() {

    int daysLeft =
        endDate.difference(DateTime.now()).inDays;

    if (daysLeft <= 0) {
      return 0;
    }

    return remainingBalance / daysLeft;
  }
}
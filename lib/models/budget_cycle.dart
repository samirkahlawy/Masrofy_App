import 'expense.dart';

class BudgetCycle {
  final int? id;
  final int userId;
  final double totalAllowance;
  final double remainingBalance;
  final DateTime startDate;
  final DateTime endDate;
  final List<Expense> expenses;

  BudgetCycle({
    this.id,
    required this.userId,
    required this.totalAllowance,
    required this.remainingBalance,
    required this.startDate,
    required this.endDate,
    this.expenses = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'total_allowance': totalAllowance,
      'remaining_balance': remainingBalance,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }

  factory BudgetCycle.fromMap(Map<String, dynamic> map) {
    return BudgetCycle(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      totalAllowance: (map['total_allowance'] as num).toDouble(),
      remainingBalance: (map['remaining_balance'] as num).toDouble(),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
    );
  }

  bool isExpired() {
    return DateTime.now().isAfter(endDate);
  }

  double calculateDailyLimit() {
    final totalDays = endDate.difference(startDate).inDays + 1;
    if (totalDays <= 0) return 0;
    return totalAllowance / totalDays;
  }
}

import 'expense.dart';

/// Represents a specific financial period with a set budget and date range.
class BudgetCycle {
  /// The unique identifier for the budget cycle.
  final int? id;

  /// The ID of the user this budget cycle belongs to.
  final int userId;

  /// The total amount of money allocated for this cycle.
  final double totalAllowance;

  /// The current remaining balance in the cycle.
  final double remainingBalance;

  /// The start date of the budget cycle.
  final DateTime startDate;

  /// The end date of the budget cycle.
  final DateTime endDate;

  /// A list of [Expense] items recorded during this cycle.
  final List<Expense> expenses;

  /// Creates a [BudgetCycle] instance.
  BudgetCycle({
    this.id,
    required this.userId,
    required this.totalAllowance,
    required this.remainingBalance,
    required this.startDate,
    required this.endDate,
    this.expenses = const [],
  });

  /// Converts the [BudgetCycle] instance into a [Map] for database or JSON storage.
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

  /// Creates a [BudgetCycle] instance from a [Map].
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

  /// Returns `true` if the current date is past the [endDate].
  bool isExpired() {
    return DateTime.now().isAfter(endDate);
  }

  /// Calculates the recommended daily spending limit based on the total allowance 
  /// and the number of days in the cycle.
  double calculateDailyLimit() {
    final totalDays = endDate.difference(startDate).inDays + 1;
    if (totalDays <= 0) return 0;
    return totalAllowance / totalDays;
  }
}
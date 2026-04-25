class BudgetCycle {
  final int? id;
  final int userId;
  final DateTime startDate;
  final DateTime endDate;
  final double budgetAmount;

  BudgetCycle({
    this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.budgetAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'budget_amount': budgetAmount,
    };
  }

  factory BudgetCycle.fromMap(Map<String, dynamic> map) {
    return BudgetCycle(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      budgetAmount: (map['budget_amount'] as num).toDouble(),
    );
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  double get remainingAmount => budgetAmount;
  double get usedPercentage => 0;
}

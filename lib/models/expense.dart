class Expense {
  final int? id;
  final double amount;
  final String? description;
  final int? categoryId;
  final DateTime date;
  final int? userId;

  Expense({
    this.id,
    required this.amount,
    this.description,
    this.categoryId,
    required this.date,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'user_id': userId,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String?,
      categoryId: map['category_id'] as int?,
      date: DateTime.parse(map['date'] as String),
      userId: map['user_id'] as int?,
    );
  }

  Expense copyWith({
    int? id,
    double? amount,
    String? description,
    int? categoryId,
    DateTime? date,
    int? userId,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }
}

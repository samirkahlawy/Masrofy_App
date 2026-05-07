class Expense {
  final int? id;
  final double amount;
  final String? note;
  final int? categoryId;
  final DateTime date;
  final int? userId;

  Expense({
    this.id,
    required this.amount,
    this.note,
    this.categoryId,
    required this.date,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'user_id': userId,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
      categoryId: map['category_id'] as int?,
      date: DateTime.parse(map['date'] as String),
      userId: map['user_id'] as int?,
    );
  }

  Expense copyWith({
    int? id,
    double? amount,
    String? note,
    int? categoryId,
    DateTime? date,
    int? userId,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }
}

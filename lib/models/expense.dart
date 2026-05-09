/// Represents a single financial transaction or expenditure.
class Expense {
  /// The unique identifier for the expense.
  final int? id;

  /// The monetary amount of the expense.
  final double amount;

  /// An optional note or description for the expense.
  final String? note;

  /// The ID of the [Category] this expense belongs to.
  final int? categoryId;

  /// The date and time when the expense occurred.
  final DateTime date;

  /// The ID of the [User] who recorded this expense.
  final int? userId;

  /// Creates an [Expense] instance.
  Expense({
    this.id,
    required this.amount,
    this.note,
    this.categoryId,
    required this.date,
    this.userId,
  });

  /// Converts the [Expense] instance into a [Map] for storage.
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

  /// Creates an [Expense] instance from a [Map].
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

  /// Creates a copy of this expense with updated fields.
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

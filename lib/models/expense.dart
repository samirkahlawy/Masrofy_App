class Expense {

  int? id;

  double amount;

  String note;

  int categoryId;

  DateTime date;

  int userId;

  Expense({
    this.id,
    required this.amount,
    required this.note,
    required this.categoryId,
    required this.date,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'userId': userId,
    };
  }

  factory Expense.fromMap(
    Map<String, dynamic> map,
  ) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      note: map['note'],
      categoryId: map['categoryId'],
      date: DateTime.parse(map['date']),
      userId: map['userId'],
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
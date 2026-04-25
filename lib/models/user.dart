class User {
  final int? id;
  final String name;
  final String? email;
  final double monthlyBudget;
  final DateTime createdAt;

  User({
    this.id,
    required this.name,
    this.email,
    this.monthlyBudget = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'monthly_budget': monthlyBudget,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String?,
      monthlyBudget: (map['monthly_budget'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    double? monthlyBudget,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

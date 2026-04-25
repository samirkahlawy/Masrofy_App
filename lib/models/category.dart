class Category {
  final int? id;
  final String name;
  final String? icon;
  final String? color;
  final int? userId;

  Category({this.id, required this.name, this.icon, this.color, this.userId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'user_id': userId,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      userId: map['user_id'] as int?,
    );
  }

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    int? userId,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      userId: userId ?? this.userId,
    );
  }
}

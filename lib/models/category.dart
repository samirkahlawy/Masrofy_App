class Category {

  int? id;

  String name;

  String iconPath;

  Category({
    this.id,
    required this.name,
    required this.iconPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
    };
  }

  factory Category.fromMap(
    Map<String, dynamic> map,
  ) {
    return Category(
      id: map['id'],
      name: map['name'],
      iconPath: map['iconPath'],
    );
  }

  Category copyWith({
    int? id,
    String? name,
    String? iconPath,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
    );
  }
}
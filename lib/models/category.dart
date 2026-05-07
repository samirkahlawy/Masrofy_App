class Category {
  final int? id;
  final String name;
  final String? iconPath;

  Category({this.id, required this.name, this.iconPath});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'icon_path': iconPath};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconPath: map['icon_path'] as String?,
    );
  }

  Category copyWith({int? id, String? name, String? iconPath}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
    );
  }
}

/// Represents a category for grouping expenses (e.g., Food, Transport).
class Category {
  /// The unique identifier for the category.
  final int? id;

  /// The display name of the category.
  final String name;

  /// Optional path to an icon asset or identifier for the category.
  final String? iconPath;

  /// Creates a [Category] instance.
  Category({this.id, required this.name, this.iconPath});

  /// Converts the [Category] instance into a [Map] for storage.
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'icon_path': iconPath};
  }

  /// Creates a [Category] instance from a [Map].
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconPath: map['icon_path'] as String?,
    );
  }

  /// Creates a copy of this category with updated fields.
  Category copyWith({int? id, String? name, String? iconPath}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
    );
  }
}
class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory CategoryModel.fromString(String categoryName) {
    return CategoryModel(
      id: categoryName.toLowerCase().replaceAll(' ', '_'),
      name: categoryName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}

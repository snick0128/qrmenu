enum MenuItemType {
  food,
  beverage,
  dessert,
  other,
  vegetarian,
  spicy,
  chefSpecial
}

class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String category;
  final List<MenuItemType> types;
  final bool isAvailable;
  final bool isPopular;
  final double rating;
  final int reviewCount;
  final String? preparationTime;
  final int? position;
  final Map<String, dynamic>? customization;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    this.types = const [],
    this.isAvailable = true,
    this.isPopular = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.preparationTime,
    this.position,
    this.customization,
  });

  bool get isVeg => types.contains(MenuItemType.vegetarian);
  bool get isSpicy => types.contains(MenuItemType.spicy);
  bool get isChefSpecial => types.contains(MenuItemType.chefSpecial);

  MenuItemModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    List<MenuItemType>? types,
    bool? isAvailable,
    bool? isPopular,
    double? rating,
    int? reviewCount,
    String? preparationTime,
    int? position,
    Map<String, dynamic>? customization,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      types: types ?? this.types,
      isAvailable: isAvailable ?? this.isAvailable,
      isPopular: isPopular ?? this.isPopular,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      preparationTime: preparationTime ?? this.preparationTime,
      position: position ?? this.position,
      customization: customization ?? this.customization,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'types': types.map((t) => t.toString().split('.').last).toList(),
      'isAvailable': isAvailable,
      'isPopular': isPopular,
      'rating': rating,
      'reviewCount': reviewCount,
      'preparationTime': preparationTime,
      'position': position,
      'customization': customization,
    };
  }

  static MenuItemModel fromMap(Map<String, dynamic> map) {
    return MenuItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      price: map['price'] as double,
      imageUrl: map['imageUrl'] as String?,
      category: map['category'] as String,
      types: (map['types'] as List<dynamic>?)?.map((type) => 
        MenuItemType.values.firstWhere(
          (t) => t.toString().split('.').last == type,
        )
      ).toList() ?? const [],
      isAvailable: map['isAvailable'] as bool? ?? true,
      isPopular: map['isPopular'] as bool? ?? false,
      rating: map['rating'] as double? ?? 0.0,
      reviewCount: map['reviewCount'] as int? ?? 0,
      preparationTime: map['preparationTime'] as String?,
      position: map['position'] as int?,
      customization: map['customization'] as Map<String, dynamic>?,
    );
  }
}
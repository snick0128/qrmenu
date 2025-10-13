import 'package:json_annotation/json_annotation.dart';

part 'menu_item_model.g.dart';

@JsonSerializable()
class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool isVeg;
  final bool isSpicy;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final List<String> allergens;
  final Map<String, dynamic> nutritionalInfo;
  final bool isPopular;
  final bool isQuickOrder;
  final String preparationTime;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isVeg = false,
    this.isSpicy = false,
    this.isAvailable = true,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.allergens = const [],
    this.nutritionalInfo = const {},
    this.isPopular = false,
    this.isQuickOrder = false,
    this.preparationTime = '15-20 min',
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) =>
      _$MenuItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemModelToJson(this);

  MenuItemModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isVeg,
    bool? isSpicy,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    List<String>? allergens,
    Map<String, dynamic>? nutritionalInfo,
    bool? isPopular,
    bool? isQuickOrder,
    String? preparationTime,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isVeg: isVeg ?? this.isVeg,
      isSpicy: isSpicy ?? this.isSpicy,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      allergens: allergens ?? this.allergens,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      isPopular: isPopular ?? this.isPopular,
      isQuickOrder: isQuickOrder ?? this.isQuickOrder,
      preparationTime: preparationTime ?? this.preparationTime,
    );
  }
}

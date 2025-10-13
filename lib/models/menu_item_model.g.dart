// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItemModel _$MenuItemModelFromJson(
  Map<String, dynamic> json,
) => MenuItemModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  category: json['category'] as String,
  imageUrl: json['imageUrl'] as String,
  isVeg: json['isVeg'] as bool? ?? false,
  isSpicy: json['isSpicy'] as bool? ?? false,
  isAvailable: json['isAvailable'] as bool? ?? true,
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  allergens:
      (json['allergens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  nutritionalInfo: json['nutritionalInfo'] as Map<String, dynamic>? ?? const {},
  isPopular: json['isPopular'] as bool? ?? false,
  isQuickOrder: json['isQuickOrder'] as bool? ?? false,
  preparationTime: json['preparationTime'] as String? ?? '15-20 min',
);

Map<String, dynamic> _$MenuItemModelToJson(MenuItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'category': instance.category,
      'imageUrl': instance.imageUrl,
      'isVeg': instance.isVeg,
      'isSpicy': instance.isSpicy,
      'isAvailable': instance.isAvailable,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'allergens': instance.allergens,
      'nutritionalInfo': instance.nutritionalInfo,
      'isPopular': instance.isPopular,
      'isQuickOrder': instance.isQuickOrder,
      'preparationTime': instance.preparationTime,
    };

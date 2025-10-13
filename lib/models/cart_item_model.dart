import 'package:json_annotation/json_annotation.dart';
import 'menu_item_model.dart';

part 'cart_item_model.g.dart';

@JsonSerializable()
class CartItemModel {
  final String id;
  final MenuItemModel menuItem;
  final int quantity;
  final String? specialInstructions;
  final DateTime addedAt;
  final String? status;
  final bool? addedByCounter;

  const CartItemModel({
    required this.id,
    required this.menuItem,
    required this.quantity,
    this.specialInstructions,
    required this.addedAt,
    this.status,
    this.addedByCounter = false,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  double get totalPrice => menuItem.price * quantity;
  
  // Convenience getters for cart drawer
  String get name => menuItem.name;
  double get price => menuItem.price;

  CartItemModel copyWith({
    String? id,
    MenuItemModel? menuItem,
    int? quantity,
    String? specialInstructions,
    DateTime? addedAt,
    String? status,
    bool? addedByCounter,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      addedAt: addedAt ?? this.addedAt,
      status: status ?? this.status,
      addedByCounter: addedByCounter ?? this.addedByCounter,
    );
  }
}

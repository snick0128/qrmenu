import 'menu_item_model.dart';

enum OrderStatus {
  pending,
  preparing,
  ready,
  delivered,
  served,
  cancelled
}

class CartItemModel {
  final String id;
  final MenuItemModel menuItem;
  final int quantity;
  final String? specialInstructions;
  final OrderStatus? status;
  final bool addedByCounter;

  const CartItemModel({
    required this.id,
    required this.menuItem,
    required this.quantity,
    this.specialInstructions,
    this.status,
    this.addedByCounter = false,
  });

  double get price => menuItem.price;
  String get name => menuItem.name;
  double get totalPrice => menuItem.price * quantity;

  CartItemModel copyWith({
    String? id,
    MenuItemModel? menuItem,
    int? quantity,
    String? specialInstructions,
    OrderStatus? status,
    bool? addedByCounter,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      status: status ?? this.status,
      addedByCounter: addedByCounter ?? this.addedByCounter,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'menuItemId': menuItem.id,
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'status': status?.toString().split('.').last,
      'addedByCounter': addedByCounter,
    };
  }

  static CartItemModel fromMap(Map<String, dynamic> map, MenuItemModel menuItem) {
    return CartItemModel(
      id: map['id'] as String,
      menuItem: menuItem,
      quantity: map['quantity'] as int,
      specialInstructions: map['specialInstructions'] as String?,
      status: map['status'] != null 
          ? OrderStatus.values.firstWhere(
              (e) => e.toString().split('.').last == map['status'],
            )
          : null,
      addedByCounter: map['addedByCounter'] as bool? ?? false,
    );
  }
}
import 'package:json_annotation/json_annotation.dart';
import 'cart_item_model.dart';

part 'order_model.g.dart';

enum OrderStatus { pending, preparing, ready, served, cancelled }

@JsonSerializable()
class OrderModel {
  final String id;
  final String restaurantName;
  final String? tableNumber;
  final List<CartItemModel> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderDate;
  final String paymentMethod;
  final String orderType;
  final String? deliveryAddress;

  const OrderModel({
    required this.id,
    required this.restaurantName,
    this.tableNumber,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.paymentMethod,
    required this.orderType,
    this.deliveryAddress,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  OrderModel copyWith({
    String? id,
    String? restaurantName,
    String? tableNumber,
    List<CartItemModel>? items,
    double? totalAmount,
    OrderStatus? status,
    DateTime? orderDate,
    String? paymentMethod,
    String? orderType,
    String? deliveryAddress,
  }) {
    return OrderModel(
      id: id ?? this.id,
      restaurantName: restaurantName ?? this.restaurantName,
      tableNumber: tableNumber ?? this.tableNumber,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderType: orderType ?? this.orderType,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    );
  }
}

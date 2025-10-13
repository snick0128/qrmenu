// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: json['id'] as String,
  restaurantName: json['restaurantName'] as String,
  tableNumber: json['tableNumber'] as String?,
  items: (json['items'] as List<dynamic>)
      .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  orderDate: DateTime.parse(json['orderDate'] as String),
  paymentMethod: json['paymentMethod'] as String,
  orderType: json['orderType'] as String,
  deliveryAddress: json['deliveryAddress'] as String?,
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'restaurantName': instance.restaurantName,
      'tableNumber': instance.tableNumber,
      'items': instance.items,
      'totalAmount': instance.totalAmount,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'orderDate': instance.orderDate.toIso8601String(),
      'paymentMethod': instance.paymentMethod,
      'orderType': instance.orderType,
      'deliveryAddress': instance.deliveryAddress,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.preparing: 'preparing',
  OrderStatus.ready: 'ready',
  OrderStatus.served: 'served',
  OrderStatus.cancelled: 'cancelled',
};

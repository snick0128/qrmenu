import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

part 'dining_session.g.dart';

@JsonSerializable(explicitToJson: true)
class DiningSession {
  final String? id;
  final String type; // 'dine-in' or 'parcel'
  final String status;
  final String? tableNumber;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? startTime;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? endTime;
  final double totalAmount;
  final String? paymentMethod;
  @JsonKey(fromJson: _itemsFromJson, toJson: _itemsToJson)
  final List<CartItemModel> items;

  static DateTime? _timestampFromJson(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    return null;
  }

  static dynamic _timestampToJson(DateTime? time) {
    if (time == null) return null;
    return Timestamp.fromDate(time);
  }

  static List<CartItemModel> _itemsFromJson(List<dynamic> itemList) {
    return itemList
        .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _itemsToJson(List<CartItemModel> items) {
    return items.map((item) => item.toJson()).toList();
  }

  DiningSession({
    this.id,
    required this.type,
    this.status = 'pending',
    this.tableNumber,
    this.startTime,
    this.endTime,
    this.totalAmount = 0.0,
    this.paymentMethod,
    required this.items,
  });

  factory DiningSession.fromJson(Map<String, dynamic> json) =>
      _$DiningSessionFromJson(json);
  Map<String, dynamic> toJson() => _$DiningSessionToJson(this);

  DiningSession copyWith({
    String? id,
    String? type,
    String? status,
    String? tableNumber,
    DateTime? startTime,
    DateTime? endTime,
    double? totalAmount,
    String? paymentMethod,
    List<CartItemModel>? items,
  }) {
    return DiningSession(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      tableNumber: tableNumber ?? this.tableNumber,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
    );
  }
}

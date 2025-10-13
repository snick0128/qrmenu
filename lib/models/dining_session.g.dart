// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dining_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiningSession _$DiningSessionFromJson(Map<String, dynamic> json) =>
    DiningSession(
      id: json['id'] as String?,
      type: json['type'] as String,
      status: json['status'] as String? ?? 'pending',
      tableNumber: json['tableNumber'] as String?,
      startTime: DiningSession._timestampFromJson(json['startTime']),
      endTime: DiningSession._timestampFromJson(json['endTime']),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as String?,
      items: DiningSession._itemsFromJson(json['items'] as List),
    );

Map<String, dynamic> _$DiningSessionToJson(DiningSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'status': instance.status,
      'tableNumber': instance.tableNumber,
      'startTime': DiningSession._timestampToJson(instance.startTime),
      'endTime': DiningSession._timestampToJson(instance.endTime),
      'totalAmount': instance.totalAmount,
      'paymentMethod': instance.paymentMethod,
      'items': DiningSession._itemsToJson(instance.items),
    };

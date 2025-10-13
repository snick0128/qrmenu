// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentStatus _$PaymentStatusFromJson(Map<String, dynamic> json) =>
    PaymentStatus(
      orderId: json['orderId'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      timestamp: PaymentStatus._timestampFromJson(json['timestamp']),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$PaymentStatusToJson(PaymentStatus instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'status': instance.status,
      'amount': instance.amount,
      'method': instance.method,
      'timestamp': PaymentStatus._timestampToJson(instance.timestamp),
      'note': instance.note,
    };

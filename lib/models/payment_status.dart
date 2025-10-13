import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'payment_status.g.dart';

@JsonSerializable(explicitToJson: true)
class PaymentStatus {
  final String orderId;
  final String status;
  final double amount;
  final String method;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime timestamp;
  final String? note;

  PaymentStatus({
    required this.orderId,
    required this.status,
    required this.amount,
    required this.method,
    required this.timestamp,
    this.note,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) =>
      _$PaymentStatusFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentStatusToJson(this);

  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    return DateTime.now();
  }

  static dynamic _timestampToJson(DateTime time) => Timestamp.fromDate(time);
}

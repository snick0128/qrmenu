import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'guest_session.g.dart';

@JsonSerializable()
class GuestSession {
  final String guestUid;
  final String hotelId;
  final String tableNo;
  final String? activeOrderId;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  const GuestSession({
    required this.guestUid,
    required this.hotelId,
    required this.tableNo,
    this.activeOrderId,
    required this.createdAt,
  });

  factory GuestSession.fromJson(Map<String, dynamic> json) =>
      _$GuestSessionFromJson(json);

  Map<String, dynamic> toJson() => _$GuestSessionToJson(this);

  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    return DateTime.now();
  }

  static dynamic _timestampToJson(DateTime time) {
    return Timestamp.fromDate(time);
  }
}

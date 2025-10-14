// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuestSession _$GuestSessionFromJson(Map<String, dynamic> json) => GuestSession(
  guestUid: json['guestUid'] as String,
  hotelId: json['hotelId'] as String,
  tableNo: json['tableNo'] as String,
  activeOrderId: json['activeOrderId'] as String?,
  createdAt: GuestSession._timestampFromJson(json['createdAt']),
);

Map<String, dynamic> _$GuestSessionToJson(GuestSession instance) =>
    <String, dynamic>{
      'guestUid': instance.guestUid,
      'hotelId': instance.hotelId,
      'tableNo': instance.tableNo,
      'activeOrderId': instance.activeOrderId,
      'createdAt': GuestSession._timestampToJson(instance.createdAt),
    };

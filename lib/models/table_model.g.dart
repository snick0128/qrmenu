// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TableModel _$TableModelFromJson(Map<String, dynamic> json) => TableModel(
  id: json['id'] as String,
  name: json['name'] as String,
  number: (json['number'] as num).toInt(),
  capacity: (json['capacity'] as num?)?.toInt() ?? 4,
  status:
      $enumDecodeNullable(_$TableStatusEnumMap, json['status']) ??
      TableStatus.vacant,
  sessionId: json['sessionId'] as String?,
  reservedBy: json['reservedBy'] as String?,
  currentTotal: (json['currentTotal'] as num?)?.toDouble() ?? 0.0,
  reservedAt: TableModel._timestampFromJson(json['reservedAt']),
  lastUpdated: TableModel._timestampFromJson(json['lastUpdated']),
);

Map<String, dynamic> _$TableModelToJson(TableModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'number': instance.number,
      'capacity': instance.capacity,
      'status': _$TableStatusEnumMap[instance.status]!,
      'sessionId': instance.sessionId,
      'reservedBy': instance.reservedBy,
      'currentTotal': instance.currentTotal,
      'reservedAt': TableModel._timestampToJson(instance.reservedAt),
      'lastUpdated': TableModel._timestampToJson(instance.lastUpdated),
    };

const _$TableStatusEnumMap = {
  TableStatus.vacant: 'vacant',
  TableStatus.reserved: 'reserved',
  TableStatus.occupied: 'occupied',
  TableStatus.cleaning: 'cleaning',
};

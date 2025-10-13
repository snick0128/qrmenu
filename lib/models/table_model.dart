import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'table_model.g.dart';

enum TableStatus {
  vacant,
  reserved,
  occupied,
  cleaning,
}

@JsonSerializable()
class TableModel {
  final String id;
  final String name;
  final int number;
  final int capacity;
  final TableStatus status;
  final String? sessionId;
  final String? reservedBy;
  final double currentTotal;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? reservedAt;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? lastUpdated;

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

  const TableModel({
    required this.id,
    required this.name,
    required this.number,
    this.capacity = 4,
    this.status = TableStatus.vacant,
    this.sessionId,
    this.reservedBy,
    this.currentTotal = 0.0,
    this.reservedAt,
    this.lastUpdated,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) =>
      _$TableModelFromJson(json);

  Map<String, dynamic> toJson() => _$TableModelToJson(this);

  TableModel copyWith({
    String? id,
    String? name,
    int? number,
    int? capacity,
    TableStatus? status,
    String? sessionId,
    String? reservedBy,
    double? currentTotal,
    DateTime? reservedAt,
    DateTime? lastUpdated,
  }) {
    return TableModel(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      sessionId: sessionId ?? this.sessionId,
      reservedBy: reservedBy ?? this.reservedBy,
      currentTotal: currentTotal ?? this.currentTotal,
      reservedAt: reservedAt ?? this.reservedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  String get statusText {
    switch (status) {
      case TableStatus.vacant:
        return 'Vacant';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.cleaning:
        return 'Cleaning';
    }
  }
}
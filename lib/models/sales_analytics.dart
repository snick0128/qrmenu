import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'sales_analytics.g.dart';

@JsonSerializable()
class SalesAnalytics {
  final int totalOrders;
  final double totalSales;
  final int ongoingOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double averageOrderValue;
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

  const SalesAnalytics({
    this.totalOrders = 0,
    this.totalSales = 0.0,
    this.ongoingOrders = 0,
    this.completedOrders = 0,
    this.cancelledOrders = 0,
    this.averageOrderValue = 0.0,
    this.lastUpdated,
  });

  factory SalesAnalytics.fromJson(Map<String, dynamic> json) =>
      _$SalesAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$SalesAnalyticsToJson(this);

  SalesAnalytics copyWith({
    int? totalOrders,
    double? totalSales,
    int? ongoingOrders,
    int? completedOrders,
    int? cancelledOrders,
    double? averageOrderValue,
    DateTime? lastUpdated,
  }) {
    return SalesAnalytics(
      totalOrders: totalOrders ?? this.totalOrders,
      totalSales: totalSales ?? this.totalSales,
      ongoingOrders: ongoingOrders ?? this.ongoingOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

enum DateFilterType { today, week, month }

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesAnalytics _$SalesAnalyticsFromJson(Map<String, dynamic> json) =>
    SalesAnalytics(
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0.0,
      ongoingOrders: (json['ongoingOrders'] as num?)?.toInt() ?? 0,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
      cancelledOrders: (json['cancelledOrders'] as num?)?.toInt() ?? 0,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: SalesAnalytics._timestampFromJson(json['lastUpdated']),
    );

Map<String, dynamic> _$SalesAnalyticsToJson(SalesAnalytics instance) =>
    <String, dynamic>{
      'totalOrders': instance.totalOrders,
      'totalSales': instance.totalSales,
      'ongoingOrders': instance.ongoingOrders,
      'completedOrders': instance.completedOrders,
      'cancelledOrders': instance.cancelledOrders,
      'averageOrderValue': instance.averageOrderValue,
      'lastUpdated': SalesAnalytics._timestampToJson(instance.lastUpdated),
    };

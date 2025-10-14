// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_analytics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuAnalyticsModel _$MenuAnalyticsModelFromJson(Map<String, dynamic> json) =>
    MenuAnalyticsModel(
      mostOrdered: Map<String, int>.from(json['mostOrdered'] as Map),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$MenuAnalyticsModelToJson(MenuAnalyticsModel instance) =>
    <String, dynamic>{
      'mostOrdered': instance.mostOrdered,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

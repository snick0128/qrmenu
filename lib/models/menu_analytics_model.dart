import 'package:json_annotation/json_annotation.dart';

part 'menu_analytics_model.g.dart';

@JsonSerializable()
class MenuAnalyticsModel {
  final Map<String, int> mostOrdered; // Map of itemId to order count
  final DateTime lastUpdated;

  const MenuAnalyticsModel({
    required this.mostOrdered,
    required this.lastUpdated,
  });

  factory MenuAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      _$MenuAnalyticsModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuAnalyticsModelToJson(this);

  MenuAnalyticsModel copyWith({
    Map<String, int>? mostOrdered,
    DateTime? lastUpdated,
  }) {
    return MenuAnalyticsModel(
      mostOrdered: mostOrdered ?? this.mostOrdered,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

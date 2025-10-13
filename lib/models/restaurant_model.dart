import 'package:json_annotation/json_annotation.dart';

part 'restaurant_model.g.dart';

@JsonSerializable()
class RestaurantModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String? tableNumber;
  final String logoUrl;
  final Map<String, dynamic> settings;
  final bool isActive;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.tableNumber,
    required this.logoUrl,
    this.settings = const {},
    this.isActive = true,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantModelFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantModelToJson(this);
}

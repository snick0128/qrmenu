import 'package:json_annotation/json_annotation.dart';

part 'menu_category_model.g.dart';

@JsonSerializable()
class MenuCategoryModel {
  final String id;
  final String name;
  final String? description;

  const MenuCategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$MenuCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuCategoryModelToJson(this);
}

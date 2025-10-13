import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import '../models/menu_item_model.dart';
import '../models/restaurant_model.dart';

/// Local seeder that reads `assets/mock_data/seeded_data.json` and returns
/// parsed objects. It does NOT write to Firestore. Use this to populate UI
/// locally during development or run the producer that writes to Firestore
/// separately when you enable Firebase.
class SeedData {
  static Future<RestaurantModel> loadRestaurant() async {
    final raw = await rootBundle.loadString(
      'assets/mock_data/seeded_data.json',
    );
    final Map<String, dynamic> jsonMap =
        json.decode(raw) as Map<String, dynamic>;
    final rest = jsonMap['restaurant'] as Map<String, dynamic>;

    return RestaurantModel(
      id: rest['id'] as String,
      name: rest['name'] as String,
      address: rest['address'] as String,
      phone: rest['phone'] as String,
      tableNumber: rest['tableNumber'] as String?,
      logoUrl: rest['logoUrl'] as String,
      settings: Map<String, dynamic>.from(rest['settings'] as Map),
    );
  }

  static Future<List<MenuItemModel>> loadMenuItems() async {
    final raw = await rootBundle.loadString(
      'assets/mock_data/seeded_data.json',
    );
    final Map<String, dynamic> jsonMap =
        json.decode(raw) as Map<String, dynamic>;
    final items = jsonMap['menuItems'] as List<dynamic>;

    return items
        .map((e) => MenuItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}

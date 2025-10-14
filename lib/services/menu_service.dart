import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';
import 'firebase_service.dart';

class MenuService {
  static final CollectionReference _menuCollection = FirebaseService.firestore
      .collection('menu_items');

  // Fetch all menu items
  static Future<List<MenuItemModel>> getAllMenuItems() async {
    try {
      final QuerySnapshot snapshot = await _menuCollection.get();
      return snapshot.docs
          .map(
            (doc) => MenuItemModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error fetching menu items: $e');
      rethrow;
    }
  }

  // Fetch menu items by category
  static Future<List<MenuItemModel>> getMenuItemsByCategory(
    String category,
  ) async {
    try {
      final QuerySnapshot snapshot = await _menuCollection
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs
          .map(
            (doc) => MenuItemModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error fetching menu items by category: $e');
      rethrow;
    }
  }

  // Fetch popular menu items
  static Future<List<MenuItemModel>> getPopularItems() async {
    try {
      final QuerySnapshot snapshot = await _menuCollection
          .where('isPopular', isEqualTo: true)
          .limit(10)
          .get();
      return snapshot.docs
          .map(
            (doc) => MenuItemModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error fetching popular items: $e');
      rethrow;
    }
  }

  // Search menu items
  static Future<List<MenuItemModel>> searchMenuItems(String query) async {
    try {
      final QuerySnapshot snapshot = await _menuCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      return snapshot.docs
          .map(
            (doc) => MenuItemModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error searching menu items: $e');
      rethrow;
    }
  }

  // Get menu item by ID
  static Future<MenuItemModel?> getMenuItemById(String id) async {
    try {
      final DocumentSnapshot doc = await _menuCollection.doc(id).get();
      if (!doc.exists) return null;
      return MenuItemModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      print('Error fetching menu item by ID: $e');
      rethrow;
    }
  }
}

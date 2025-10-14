import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';
import 'firebase_service.dart';

class CartService extends ChangeNotifier {
  final String _cartId;
  final List<CartItemModel> _items = [];
  final CollectionReference _cartsCollection = FirebaseService.firestore
      .collection('carts');

  CartService(this._cartId) {
    _loadCart();
  }

  // Getters
  List<CartItemModel> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  double get totalAmount =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => _items.isEmpty;

  // Load cart from Firestore
  Future<void> _loadCart() async {
    try {
      final DocumentSnapshot cartDoc = await _cartsCollection
          .doc(_cartId)
          .get();
      if (cartDoc.exists) {
        final data = cartDoc.data() as Map<String, dynamic>;
        final List<dynamic> itemsData = data['items'] ?? [];
        _items.clear();
        _items.addAll(
          itemsData.map(
            (item) => CartItemModel.fromJson(item as Map<String, dynamic>),
          ),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  // Save cart to Firestore
  Future<void> _saveCart() async {
    try {
      await _cartsCollection.doc(_cartId).set({
        'items': _items.map((item) => item.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving cart: $e');
      rethrow;
    }
  }

  // Add item to cart
  Future<void> addItem(
    MenuItemModel menuItem, {
    int quantity = 1,
    String? specialInstructions,
  }) async {
    final existingItemIndex = _items.indexWhere(
      (i) => i.menuItem.id == menuItem.id,
    );

    if (existingItemIndex >= 0) {
      // Update existing item quantity
      final existingItem = _items[existingItemIndex];
      _items[existingItemIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Add new item
      _items.add(
        CartItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          menuItem: menuItem,
          quantity: quantity,
          specialInstructions: specialInstructions,
          addedAt: DateTime.now(),
        ),
      );
    }

    notifyListeners();
    await _saveCart();
  }

  // Update item quantity
  Future<void> updateItemQuantity(String itemId, int quantity) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      notifyListeners();
      await _saveCart();
    }
  }

  // Remove item from cart
  Future<void> removeItem(String itemId) async {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
    await _saveCart();
  }

  // Clear cart
  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    await _saveCart();
  }

  // Update special instructions
  Future<void> updateSpecialInstructions(
    String itemId,
    String? instructions,
  ) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(specialInstructions: instructions);
      notifyListeners();
      await _saveCart();
    }
  }
}

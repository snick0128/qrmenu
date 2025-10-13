import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';

class OrderHistoryProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  static const String _ordersKey = 'order_history';

  List<OrderModel> get orders => List.unmodifiable(_orders.reversed);

  Future<void> loadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getStringList(_ordersKey) ?? [];
      
      _orders = ordersJson.map((json) {
        try {
          return OrderModel.fromJson(jsonDecode(json));
        } catch (e) {
          debugPrint('Error parsing order: $e');
          return null;
        }
      }).whereType<OrderModel>().toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading orders: $e');
      // Initialize with mock data for demo
      _initializeMockData();
    }
  }

  Future<void> saveOrder(OrderModel order) async {
    try {
      _orders.add(order);
      await _saveToStorage();
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving order: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = _orders.map((order) => jsonEncode(order.toJson())).toList();
      await prefs.setStringList(_ordersKey, ordersJson);
    } catch (e) {
      debugPrint('Error saving to storage: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      _orders.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_ordersKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }

  void _initializeMockData() {
    // Create some mock orders for demo purposes
    final mockOrders = [
      OrderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString().substring(7),
        restaurantName: '🍕 Pizza Palace',
        tableNumber: '12',
        items: [
          CartItemModel(
            id: '1',
            menuItem: const MenuItemModel(
              id: 'pizza1',
              name: 'Margherita Pizza',
              description: 'Classic pizza with tomato and mozzarella',
              price: 299,
              category: 'Pizza',
              imageUrl: '',
              isVeg: true,
            ),
            quantity: 1,
            specialInstructions: 'Extra cheese',
            addedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          CartItemModel(
            id: '2',
            menuItem: const MenuItemModel(
              id: 'drink1',
              name: 'Coca Cola',
              description: 'Chilled soft drink',
              price: 60,
              category: 'Beverages',
              imageUrl: '',
              isVeg: true,
            ),
            quantity: 2,
            addedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
        totalAmount: 419,
        status: OrderStatus.served,
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        paymentMethod: 'UPI',
        orderType: 'Dine In',
      ),
      OrderModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1000).toString().substring(7),
        restaurantName: '🍔 Burger King',
        items: [
          CartItemModel(
            id: '3',
            menuItem: const MenuItemModel(
              id: 'burger1',
              name: 'Whopper Burger',
              description: 'Flame-grilled beef burger',
              price: 199,
              category: 'Burgers',
              imageUrl: '',
              isVeg: false,
            ),
            quantity: 1,
            addedAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ],
        totalAmount: 234,
        status: OrderStatus.served,
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        paymentMethod: 'Cash',
        orderType: 'Takeaway',
        deliveryAddress: null,
      ),
    ];

    _orders = mockOrders;
    notifyListeners();
  }

  // Initialize with mock data on first load
  Future<void> initializeWithMockData() async {
    await loadOrders();
    if (_orders.isEmpty) {
      _initializeMockData();
    }
  }
}

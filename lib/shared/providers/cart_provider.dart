import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  double _total = 0.0;
  bool _isLoading = false;
  bool _isOrderPlaced = false;

  List<CartItemModel> get items => _items;
  double get total => _total;
  double get totalAmount => _total;
  int get itemCount => _items.length;
  int get totalItems => _items.length;
  bool get isLoading => _isLoading;
  bool get isOrderPlaced => _isOrderPlaced;

  List<CartItemModel> get pendingItems => 
    _items.where((item) => item.status == OrderStatus.pending).toList();

  List<CartItemModel> get preparingItems =>
    _items.where((item) => item.status == OrderStatus.preparing).toList();

  List<CartItemModel> get servedItems =>
    _items.where((item) => item.status == OrderStatus.served).toList();

  int getItemQuantity(String id) {
    final index = _items.indexWhere((item) => item.menuItem.id == id);
    return index != -1 ? _items[index].quantity : 0;
  }

  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _items.length && quantity > 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _updateTotal();
      notifyListeners();
    }
  }

  void addItem(CartItemModel item) {
    _items.add(item);
    _updateTotal();
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      _updateTotal();
      notifyListeners();
    }
  }

  void increaseItemQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity + 1);
      _updateTotal();
      notifyListeners();
    }
  }

  void decreaseItemQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1 && _items[index].quantity > 1) {
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity - 1);
      _updateTotal();
      notifyListeners();
    }
  }

  void reorderItem(int index) {
    if (index >= 0 && index < _items.length) {
      final item = _items[index];
      addItem(item.copyWith(
        status: OrderStatus.pending,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      ));
    }
  }

  Future<void> placeOrder() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Update status of all pending items to preparing
      for (var i = 0; i < _items.length; i++) {
        if (_items[i].status == OrderStatus.pending) {
          _items[i] = _items[i].copyWith(status: OrderStatus.preparing);
        }
      }
      _isOrderPlaced = true;
      
      // Simulated delay for order processing
      await Future.delayed(const Duration(seconds: 2));
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _updateTotal();
    _isOrderPlaced = false;
    notifyListeners();
  }

  void _updateTotal() {
    _total = _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
}
import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';

enum DiningMode {
  dineIn,
  takeAway,
}

class DiningProvider with ChangeNotifier {
  String? _sessionId;
  String? _tableNumber;
  DiningMode? _mode;
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  String? get sessionId => _sessionId;
  String? get tableNumber => _tableNumber;
  DiningMode? get mode => _mode;
  List<Map<String, dynamic>> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isDineIn => _mode == DiningMode.dineIn;
  bool get hasActiveSession => _sessionId != null;

  // Start a new dine-in session
  Future<void> startDineInSession(String tableNumber) async {
    try {
      _setLoading(true);
      _mode = DiningMode.dineIn;
      _tableNumber = tableNumber;
      
      // Create session in Firestore
      _sessionId = await FirebaseService.createDineInSession(tableNumber);
      _items = [];
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to start dine-in session: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Start a take-away session
  void startTakeAwaySession() {
    _mode = DiningMode.takeAway;
    _tableNumber = null;
    _sessionId = null;
    _items = [];
    notifyListeners();
  }

  // Add item to order
  Future<void> addItem(Map<String, dynamic> item) async {
    try {
      _setLoading(true);
      _items.add(item);

      if (isDineIn && _sessionId != null) {
        // Update dine-in session in Firestore
        await FirebaseService.addItemToDineInSession(_sessionId!, item);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to add item: $e';
      _items.removeLast(); // Rollback on error
    } finally {
      _setLoading(false);
    }
  }

  // Remove item from order
  Future<void> removeItem(int index) async {
    try {
      _setLoading(true);
      if (index >= 0 && index < _items.length) {
        _items.removeAt(index);
        
        if (isDineIn && _sessionId != null) {
          // Update Firestore (you'll need to implement this method in FirebaseService)
          // await FirebaseService.removeItemFromDineInSession(_sessionId!, removedItem);
        }
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to remove item: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Place order
  Future<void> placeOrder() async {
    try {
      _setLoading(true);
      
      if (_items.isEmpty) {
        throw Exception('Cannot place empty order');
      }

      final double totalAmount = _items.fold(
        0,
        (sum, item) => sum + (item['price'] * item['quantity']),
      );

      if (isDineIn) {
        // Update dine-in session status
        if (_sessionId != null) {
          await FirebaseService.updateOrderStatus(_sessionId!, 'confirmed');
        }
      } else {
        // Create new takeaway order
        await FirebaseService.createParcelOrder(_items, totalAmount);
        _items = []; // Clear items after successful takeaway order
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to place order: $e';
    } finally {
      _setLoading(false);
    }
  }

  // End dine-in session
  Future<void> endSession(String paymentMethod) async {
    try {
      _setLoading(true);
      
      if (isDineIn && _sessionId != null) {
        await FirebaseService.closeDineInSession(_sessionId!, paymentMethod);
        _reset();
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to end session: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Reset provider state
  void _reset() {
    _sessionId = null;
    _tableNumber = null;
    _mode = null;
    _items = [];
    _error = null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';
import '../models/cart_item_model.dart';
import '../services/firebase_service.dart';
import '../services/order_service.dart';

enum ItemStatus { pending, preparing, served }

class CartItem {
  final MenuItemModel menuItem;
  int quantity;
  ItemStatus status;
  String? specialInstructions;
  DateTime addedAt;
  bool isReorder;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
    this.status = ItemStatus.pending,
    this.specialInstructions,
    DateTime? addedAt,
    this.isReorder = false,
  }) : addedAt = addedAt ?? DateTime.now();

  CartItem copyWith({
    MenuItemModel? menuItem,
    int? quantity,
    ItemStatus? status,
    String? specialInstructions,
    DateTime? addedAt,
    bool? isReorder,
  }) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      addedAt: addedAt ?? this.addedAt,
      isReorder: isReorder ?? this.isReorder,
    );
  }

  double get totalPrice => menuItem.price * quantity;

  // Convert to CartItemModel for UI compatibility
  CartItemModel toCartItemModel() {
    return CartItemModel(
      id: menuItem.id,
      menuItem: menuItem,
      quantity: quantity,
      specialInstructions: specialInstructions,
      addedAt: addedAt,
      status: status.name,
      addedByCounter: isReorder,
    );
  }
}

class CartProvider with ChangeNotifier {
  int getItemQuantity(String menuItemId) {
    final item = _items.firstWhere(
      (item) => item.menuItem.id == menuItemId,
      orElse: () => CartItem(
        menuItem: MenuItemModel(
          id: '',
          name: '',
          description: '',
          price: 0.0,
          category: '',
          imageUrl: '',
        ),
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  List<CartItem> _items = [];
  List<CartItem> _sessionItems =
      []; // All items from the entire session (dine-in)
  String? _sessionId;
  String? _sessionType;
  String? _tableNumber;
  bool _isOrderPlaced = false;
  bool _isLoading = false;
  String? _hotelId; // Added to track hotel ID
  String? _orderId; // Added to track active order ID

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  List<CartItem> get sessionItems => List.unmodifiable(_sessionItems);
  int get itemCount => _items.length;
  String? get sessionId => _sessionId;
  String? get sessionType => _sessionType;
  String? get tableNumber => _tableNumber;
  bool get isOrderPlaced => _isOrderPlaced;
  bool get isLoading => _isLoading;

  double get totalAmount =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get grandTotal => totalAmount;
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  List<CartItem> get pendingItems =>
      _items.where((item) => item.status == ItemStatus.pending).toList();
  List<CartItem> get preparingItems =>
      _items.where((item) => item.status == ItemStatus.preparing).toList();
  List<CartItem> get servedItems =>
      _items.where((item) => item.status == ItemStatus.served).toList();

  // Initialize session
  Future<void> initializeSession(
    String sessionId,
    String sessionType, {
    String? tableNumber,
  }) async {
    _sessionId = sessionId;
    _sessionType = sessionType;
    _tableNumber = tableNumber;
    _isOrderPlaced = false;

    // Get hotel ID if table number is provided
    if (tableNumber != null) {
      final tableDoc = await FirebaseService.accessCodes.doc(tableNumber).get();
      if (tableDoc.exists) {
        final data = tableDoc.data() as Map<String, dynamic>;
        _hotelId = data['restaurantId'] as String?;
      }
    }

    // For dine-in, try to get existing order ID
    if (_sessionType == 'dine_in' && _hotelId != null) {
      _orderId = await OrderService.getDineInOrder(_sessionId!);
    }

    notifyListeners();
  }

  // Add item to cart
  Future<void> addItem(
    MenuItemModel menuItem, {
    int quantity = 1,
    String? specialInstructions,
  }) async {
    if (_isOrderPlaced) {
      throw Exception('Cannot add items after order is placed');
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Check if item already exists
      final existingIndex = _items.indexWhere(
        (item) =>
            item.menuItem.id == menuItem.id &&
            item.status == ItemStatus.pending,
      );

      if (existingIndex != -1) {
        // Increase quantity
        _items[existingIndex] = _items[existingIndex].copyWith(
          quantity: _items[existingIndex].quantity + quantity,
        );
      } else {
        // Add new item
        final cartItem = CartItem(
          menuItem: menuItem,
          quantity: quantity,
          specialInstructions: specialInstructions,
        );
        _items.add(cartItem);
      }

      // Sync with Firebase
      if (_sessionId != null) {
        await _syncWithFirebase();
      }

      notifyListeners();
    } catch (e) {
      print('Error adding item to cart: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove item from cart
  Future<void> removeItem(int index) async {
    if (_isOrderPlaced) {
      final item = _items[index];
      if (item.status != ItemStatus.pending) {
        throw Exception('Cannot remove ${item.status.name} items');
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      _items.removeAt(index);

      // Sync with Firebase
      if (_sessionId != null) {
        await _syncWithFirebase();
      }

      notifyListeners();
    } catch (e) {
      print('Error removing item from cart: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update item quantity
  Future<void> updateQuantity(int index, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(index);
      return;
    }

    if (_isOrderPlaced) {
      final item = _items[index];
      if (item.status == ItemStatus.pending) {
        // Can increase or decrease pending items
      } else if (item.status == ItemStatus.preparing) {
        // Can only increase preparing items
        if (newQuantity < item.quantity) {
          throw Exception('Cannot decrease quantity of preparing items');
        }
      } else if (item.status == ItemStatus.served) {
        throw Exception('Cannot modify served items');
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      _items[index] = _items[index].copyWith(quantity: newQuantity);

      // Sync with Firebase
      if (_sessionId != null) {
        await _syncWithFirebase();
      }

      notifyListeners();
    } catch (e) {
      print('Error updating item quantity: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reorder served item
  Future<void> reorderItem(int index) async {
    final item = _items[index];
    if (item.status != ItemStatus.served) {
      throw Exception('Can only reorder served items');
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Create new pending item
      final reorderItem = CartItem(
        menuItem: item.menuItem,
        quantity: item.quantity,
        specialInstructions: item.specialInstructions,
        isReorder: true,
      );
      _items.add(reorderItem);

      // Sync with Firebase
      if (_sessionId != null) {
        await _syncWithFirebase();
      }

      notifyListeners();
    } catch (e) {
      print('Error reordering item: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Place order
  Future<void> placeOrder() async {
    if (_items.isEmpty) {
      throw Exception('Cart is empty');
    }

    if (_hotelId == null) {
      throw Exception('Restaurant not found');
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Note: Analytics tracking is handled inside createOrder method

      if (_sessionType == 'dine_in') {
        if (_orderId == null) {
          // Create new order for dine-in session
          _orderId = await OrderService.createOrder(
            hotelId: _hotelId!,
            tableNo: _tableNumber ?? 'unknown',
            type: 'dine_in',
            items: _items.map((i) => i.toCartItemModel()).toList(),
            total: grandTotal,
            sessionId: _sessionId,
          );
        }

        // Move items to session and clear cart for next order
        for (final item in _items) {
          final sessionItem = item.copyWith(status: ItemStatus.preparing);
          _sessionItems.add(sessionItem);
        }

        // Clear current cart for next order
        _items.clear();
        _isOrderPlaced = false; // Allow more orders
      } else {
        // Create new parcel order each time
        _orderId = await OrderService.createOrder(
          hotelId: _hotelId!,
          tableNo: _tableNumber ?? 'unknown',
          type: 'parcel',
          items: _items.map((i) => i.toCartItemModel()).toList(),
          total: grandTotal,
        );

        _isOrderPlaced = true;

        // Update all pending items to preparing
        for (int i = 0; i < _items.length; i++) {
          if (_items[i].status == ItemStatus.pending) {
            _items[i] = _items[i].copyWith(status: ItemStatus.preparing);
          }
        }
      }

      // Sync with Firebase
      if (_sessionId != null) {
        await _syncWithFirebase();
      }

      notifyListeners();
    } catch (e) {
      print('Error placing order: $e');
      _isOrderPlaced = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set order type and optional delivery address
  void setOrderType(dynamic orderType, {String? deliveryAddress}) {
    // Store order type info in sessionType for compatibility
    if (orderType is String) {
      _sessionType = orderType;
    } else {
      _sessionType = orderType?.toString();
    }
    // Delivery address can be handled by other services; here we just store tableNumber for demo
    if (deliveryAddress != null && deliveryAddress.isNotEmpty) {
      _tableNumber = deliveryAddress;
    }
    notifyListeners();
  }

  // Update item status (called by Firebase listeners)
  void updateItemStatus(int index, ItemStatus status) {
    _items[index] = _items[index].copyWith(status: status);
    notifyListeners();
  }

  // Clear cart items only (preserve session info for tracking)
  void clearCartItems() {
    _items.clear();
    notifyListeners();
  }

  // Clear cart completely (session info and items)
  void clearCart() {
    _items.clear();
    _sessionItems.clear();
    _sessionId = null;
    _sessionType = null;
    _tableNumber = null;
    _isOrderPlaced = false;
    notifyListeners();
  }

  // Sync with Firebase
  Future<void> _syncWithFirebase() async {
    if (_sessionId == null) return;

    try {
      final itemsData = _items
          .map(
            (item) => {
              'menuItemId': item.menuItem.id,
              'name': item.menuItem.name,
              'price': item.menuItem.price,
              'quantity': item.quantity,
              'status': item.status.name,
              'specialInstructions': item.specialInstructions,
              'addedAt': item.addedAt.toIso8601String(),
              'isReorder': item.isReorder,
            },
          )
          .toList();

      final sessionItemsData = _sessionItems
          .map(
            (item) => {
              'menuItemId': item.menuItem.id,
              'name': item.menuItem.name,
              'price': item.menuItem.price,
              'quantity': item.quantity,
              'status': item.status.name,
              'specialInstructions': item.specialInstructions,
              'addedAt': item.addedAt.toIso8601String(),
              'isReorder': item.isReorder,
            },
          )
          .toList();

      if (_sessionType == 'dine_in') {
        final sessionTotal = _sessionItems.fold(
          0.0,
          (sum, item) => sum + item.totalPrice,
        );

        // Update dine-in session document under the table's restaurant
        if (_tableNumber != null) {
          // First, get the restaurant ID from the table's access code
          final tableDoc = await FirebaseService.accessCodes
              .doc(_tableNumber)
              .get();
          if (tableDoc.exists) {
            final data = tableDoc.data() as Map<String, dynamic>;
            final hotelId = data['restaurantId'] as String?;
            if (hotelId != null) {
              // Update the session under the correct restaurant
              await FirebaseService.restaurants
                  .doc(hotelId)
                  .collection('dineSessions')
                  .doc(_sessionId)
                  .update({
                    'items': itemsData, // Current cart items
                    'sessionItems': sessionItemsData, // All session items
                    'totalAmount': totalAmount, // Current cart total
                    'sessionTotalAmount': sessionTotal, // Total session amount
                  });
              return;
            }
          }
        }

        // Fallback to old path if restaurant ID not found
        await FirebaseService.dineInSessions.doc(_sessionId).update({
          'items': itemsData,
          'sessionItems': sessionItemsData,
          'totalAmount': totalAmount,
          'sessionTotalAmount': sessionTotal,
        });
      } else {
        await FirebaseService.orders.doc(_sessionId).update({
          'items': itemsData,
          'totalAmount': totalAmount,
        });
      }
    } catch (e) {
      print('Error syncing with Firebase: $e');
    }
  }

  // Increase item quantity (for cart drawer compatibility)
  Future<void> increaseItemQuantity(int index) async {
    if (index >= 0 && index < _items.length) {
      await updateQuantity(index, _items[index].quantity + 1);
    }
  }

  // Decrease item quantity (for cart drawer compatibility)
  Future<void> decreaseItemQuantity(int index) async {
    if (index >= 0 && index < _items.length) {
      if (_items[index].quantity > 1) {
        await updateQuantity(index, _items[index].quantity - 1);
      } else {
        await removeItem(index);
      }
    }
  }

  // Reorder item (create new pending item from served item)
  Future<void> reorderItemByObject(dynamic item) async {
    if (item is CartItem && item.status == ItemStatus.served) {
      await addItem(
        item.menuItem,
        quantity: item.quantity,
        specialInstructions: item.specialInstructions,
      );
    }
  }

  // Load cart from Firebase
  Future<void> loadFromFirebase(String sessionId, String sessionType) async {
    _isLoading = true;
    notifyListeners();

    try {
      DocumentSnapshot? doc;

      if (sessionType == 'dine_in' && _tableNumber != null) {
        // Try to get the restaurant ID from the table's access code
        final tableDoc = await FirebaseService.accessCodes
            .doc(_tableNumber)
            .get();
        if (tableDoc.exists) {
          final data = tableDoc.data() as Map<String, dynamic>;
          final hotelId = data['restaurantId'] as String?;
          if (hotelId != null) {
            // Get the session from the restaurant's dine sessions
            doc = await FirebaseService.restaurants
                .doc(hotelId)
                .collection('dineSessions')
                .doc(sessionId)
                .get();
          }
        }
      }

      // Fallback to old paths if restaurant-specific path failed
      if (doc == null) {
        final collection = sessionType == 'dine_in'
            ? FirebaseService.dineInSessions
            : FirebaseService.orders;
        doc = await collection.doc(sessionId).get();
      }

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final itemsData = List<Map<String, dynamic>>.from(data['items'] ?? []);
        final sessionItemsData = List<Map<String, dynamic>>.from(
          data['sessionItems'] ?? [],
        );

        _items = itemsData.map((itemData) {
          // Create a basic MenuItemModel from the stored data
          final menuItem = MenuItemModel(
            id: itemData['menuItemId'] ?? '',
            name: itemData['name'] ?? '',
            description: '',
            price: (itemData['price'] ?? 0.0).toDouble(),
            category: '',
            imageUrl: '',
          );

          return CartItem(
            menuItem: menuItem,
            quantity: itemData['quantity'] ?? 1,
            status: ItemStatus.values.firstWhere(
              (status) => status.name == itemData['status'],
              orElse: () => ItemStatus.pending,
            ),
            specialInstructions: itemData['specialInstructions'],
            addedAt:
                DateTime.tryParse(itemData['addedAt'] ?? '') ?? DateTime.now(),
            isReorder: itemData['isReorder'] ?? false,
          );
        }).toList();

        // Load session items for dine-in
        if (sessionType == 'dine_in') {
          _sessionItems = sessionItemsData.map((itemData) {
            final menuItem = MenuItemModel(
              id: itemData['menuItemId'] ?? '',
              name: itemData['name'] ?? '',
              description: '',
              price: (itemData['price'] ?? 0.0).toDouble(),
              category: '',
              imageUrl: '',
            );

            return CartItem(
              menuItem: menuItem,
              quantity: itemData['quantity'] ?? 1,
              status: ItemStatus.values.firstWhere(
                (status) => status.name == itemData['status'],
                orElse: () => ItemStatus.pending,
              ),
              specialInstructions: itemData['specialInstructions'],
              addedAt:
                  DateTime.tryParse(itemData['addedAt'] ?? '') ??
                  DateTime.now(),
              isReorder: itemData['isReorder'] ?? false,
            );
          }).toList();
        }

        _sessionId = sessionId;
        _sessionType = sessionType;
        _isOrderPlaced = _items.any(
          (item) => item.status != ItemStatus.pending,
        );
      }
    } catch (e) {
      print('Error loading cart from Firebase: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

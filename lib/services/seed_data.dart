import 'package:cloud_firestore/cloud_firestore.dart';

class SeedData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedTestData() async {
    // Clear existing data first
    await _clearCollections();

    // Seed table codes
    await _seedTableCodes();

    // Seed categories
    await _seedCategories();

    // Seed menu items
    await _seedMenuItems();
  }

  static Future<void> _clearCollections() async {
    // Clear access codes
    final accessCodes = await _firestore.collection('accessCodes').get();
    for (var doc in accessCodes.docs) {
      await doc.reference.delete();
    }

    // Clear menu items
    final menuItems = await _firestore.collection('menuItems').get();
    for (var doc in menuItems.docs) {
      await doc.reference.delete();
    }

    // Clear categories
    final categories = await _firestore.collection('categories').get();
    for (var doc in categories.docs) {
      await doc.reference.delete();
    }

    // Clear dine-in sessions
    final sessions = await _firestore.collection('dineInSessions').get();
    for (var doc in sessions.docs) {
      await doc.reference.delete();
    }

    // Clear orders
    final orders = await _firestore.collection('orders').get();
    for (var doc in orders.docs) {
      await doc.reference.delete();
    }
  }

  static Future<void> _seedTableCodes() async {
    // Dine-in table codes (TBL_### format)
    for (int i = 1; i <= 10; i++) {
      await _firestore.collection('accessCodes').doc('TBL_$i').set({
        'code': 'TBL_$i',
        'type': 'dine_in',
        'tableNumber': 'Table $i',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Parcel codes (PARCEL_### format)
    for (int i = 1; i <= 5; i++) {
      await _firestore.collection('accessCodes').doc('PARCEL_$i').set({
        'code': 'PARCEL_$i',
        'type': 'parcel',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Demo codes for testing
    await _firestore.collection('accessCodes').doc('DEMO').set({
      'code': 'DEMO',
      'type': 'dine_in',
      'tableNumber': 'Demo Table',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('accessCodes').doc('TEST_PARCEL').set({
      'code': 'TEST_PARCEL',
      'type': 'parcel',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> _seedCategories() async {
    final categories = [
      {
        'name': 'Appetizers',
        'description': 'Start your meal with our delicious appetizers',
        'order': 1,
        'isActive': true,
      },
      {
        'name': 'Pizza',
        'description': 'Freshly made pizzas with premium ingredients',
        'order': 2,
        'isActive': true,
      },
      {
        'name': 'Main Course',
        'description': 'Hearty main dishes to satisfy your hunger',
        'order': 3,
        'isActive': true,
      },
      {
        'name': 'Burgers',
        'description': 'Juicy burgers made with premium beef',
        'order': 4,
        'isActive': true,
      },
      {
        'name': 'Salads',
        'description': 'Fresh and healthy salad options',
        'order': 5,
        'isActive': true,
      },
      {
        'name': 'Desserts',
        'description': 'Sweet treats to end your meal perfectly',
        'order': 6,
        'isActive': true,
      },
    ];

    for (var category in categories) {
      await _firestore.collection('categories').add(category);
    }
  }

  static Future<void> _seedMenuItems() async {
    final menuItems = [
      {
        'name': 'Classic Margherita Pizza',
        'description': 'Fresh tomatoes, mozzarella, basil, and olive oil',
        'price': 12.99,
        'category': 'Pizza',
        'imageUrl': 'https://source.unsplash.com/random/?margherita,pizza',
        'isAvailable': true,
        'isVegetarian': true,
        'spicyLevel': 0,
      },
      {
        'name': 'Chicken Tikka Masala',
        'description': 'Grilled chicken in rich tomato-based curry sauce',
        'price': 15.99,
        'category': 'Main Course',
        'imageUrl': 'https://source.unsplash.com/random/?chicken,curry',
        'isAvailable': true,
        'isVegetarian': false,
        'spicyLevel': 2,
      },
      {
        'name': 'Garden Fresh Salad',
        'description':
            'Mixed greens, cherry tomatoes, cucumber with balsamic dressing',
        'price': 8.99,
        'category': 'Salads',
        'imageUrl': 'https://source.unsplash.com/random/?salad',
        'isAvailable': true,
        'isVegetarian': true,
        'spicyLevel': 0,
      },
      {
        'name': 'Chocolate Brownie Sundae',
        'description':
            'Warm brownie topped with vanilla ice cream and chocolate sauce',
        'price': 7.99,
        'category': 'Desserts',
        'imageUrl': 'https://source.unsplash.com/random/?brownie,sundae',
        'isAvailable': true,
        'isVegetarian': true,
        'spicyLevel': 0,
      },
      {
        'name': 'Spicy Buffalo Wings',
        'description': 'Crispy chicken wings tossed in spicy buffalo sauce',
        'price': 11.99,
        'category': 'Appetizers',
        'imageUrl': 'https://source.unsplash.com/random/?buffalo,wings',
        'isAvailable': true,
        'isVegetarian': false,
        'spicyLevel': 3,
      },
      {
        'name': 'Classic Cheeseburger',
        'description':
            'Angus beef patty with cheddar, lettuce, tomato, and special sauce',
        'price': 13.99,
        'category': 'Burgers',
        'imageUrl': 'https://source.unsplash.com/random/?cheeseburger',
        'isAvailable': true,
        'isVegetarian': false,
        'spicyLevel': 0,
      },
    ];

    for (var item in menuItems) {
      await _firestore.collection('menuItems').add(item);
    }
  }
}

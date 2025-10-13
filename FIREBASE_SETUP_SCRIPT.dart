/// Firebase Setup Script for URL-based Routing
/// 
/// This script helps you set up the required Firebase Firestore data
/// for testing the new URL-based routing implementation.
/// 
/// Usage:
/// 1. Run: dart FIREBASE_SETUP_SCRIPT.dart
/// 2. Or integrate into your existing seed script

import 'package:cloud_firestore/cloud_firestore.dart';

/// Set up restaurant data for testing
Future<void> setupRestaurantData() async {
  final firestore = FirebaseFirestore.instance;

  print('🏪 Setting up restaurant data...');

  // Create demo restaurant
  await firestore.collection('restaurants').doc('demo_restaurant').set({
    'id': 'demo_restaurant',
    'name': 'Demo Restaurant',
    'address': '123 Main Street, City, State 12345',
    'phone': '+1234567890',
    'logoUrl': 'https://via.placeholder.com/150',
    'isActive': true,
    'settings': {
      'currency': 'INR',
      'taxRate': 5.0,
      'serviceCharge': 10.0,
    },
    'createdAt': FieldValue.serverTimestamp(),
  });

  print('✅ Created restaurant: demo_restaurant');

  // Create another restaurant for testing
  await firestore.collection('restaurants').doc('test_cafe').set({
    'id': 'test_cafe',
    'name': 'Test Cafe',
    'address': '456 Park Avenue, City, State 12345',
    'phone': '+0987654321',
    'logoUrl': 'https://via.placeholder.com/150',
    'isActive': true,
    'settings': {
      'currency': 'INR',
      'taxRate': 5.0,
      'serviceCharge': 5.0,
    },
    'createdAt': FieldValue.serverTimestamp(),
  });

  print('✅ Created restaurant: test_cafe');

  // Create inactive restaurant for testing
  await firestore.collection('restaurants').doc('closed_restaurant').set({
    'id': 'closed_restaurant',
    'name': 'Closed Restaurant',
    'address': '789 Old Street, City, State 12345',
    'phone': '+1122334455',
    'logoUrl': 'https://via.placeholder.com/150',
    'isActive': false,
    'settings': {},
    'createdAt': FieldValue.serverTimestamp(),
  });

  print('✅ Created restaurant: closed_restaurant');
}

/// Set up access codes for testing
Future<void> setupAccessCodes() async {
  final firestore = FirebaseFirestore.instance;

  print('\n🎫 Setting up access codes...');

  // Dine-in table codes for demo_restaurant
  final dineInTables = [
    'TBL_1',
    'TBL_2',
    'TBL_3',
    'TBL_4',
    'TBL_5',
  ];

  for (int i = 0; i < dineInTables.length; i++) {
    final tableCode = dineInTables[i];
    final isActive = i != 1; // TBL_2 will be inactive for testing

    await firestore.collection('accessCodes').doc(tableCode).set({
      'code': tableCode,
      'type': 'dine_in',
      'tableNumber': 'Table ${i + 1}',
      'isActive': isActive,
      'restaurantId': 'demo_restaurant',
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('✅ Created ${isActive ? "active" : "inactive"} table code: $tableCode');
  }

  // Parcel codes
  final parcelCodes = [
    'PARCEL_01',
    'PARCEL_02',
    'PARCEL_03',
  ];

  for (final parcelCode in parcelCodes) {
    await firestore.collection('accessCodes').doc(parcelCode).set({
      'code': parcelCode,
      'type': 'parcel',
      'tableNumber': null,
      'isActive': true,
      'restaurantId': 'demo_restaurant',
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('✅ Created parcel code: $parcelCode');
  }

  // Access codes for test_cafe
  await firestore.collection('accessCodes').doc('CAFE_TBL_1').set({
    'code': 'CAFE_TBL_1',
    'type': 'dine_in',
    'tableNumber': 'Cafe Table 1',
    'isActive': true,
    'restaurantId': 'test_cafe',
    'createdAt': FieldValue.serverTimestamp(),
  });

  print('✅ Created cafe table code: CAFE_TBL_1');
}

/// Set up sample menu items
Future<void> setupMenuItems() async {
  final firestore = FirebaseFirestore.instance;

  print('\n🍽️ Setting up menu items...');

  final menuItems = [
    {
      'id': 'item_1',
      'name': 'Chicken Biryani',
      'description': 'Aromatic rice with tender chicken pieces',
      'price': 250.0,
      'category': 'Main Course',
      'imageUrl': 'https://via.placeholder.com/300',
      'isAvailable': true,
      'isVeg': false,
      'preparationTime': 20,
      'rating': 4.5,
    },
    {
      'id': 'item_2',
      'name': 'Paneer Tikka',
      'description': 'Grilled cottage cheese with spices',
      'price': 180.0,
      'category': 'Starters',
      'imageUrl': 'https://via.placeholder.com/300',
      'isAvailable': true,
      'isVeg': true,
      'preparationTime': 15,
      'rating': 4.3,
    },
    {
      'id': 'item_3',
      'name': 'Butter Naan',
      'description': 'Soft bread with butter',
      'price': 40.0,
      'category': 'Breads',
      'imageUrl': 'https://via.placeholder.com/300',
      'isAvailable': true,
      'isVeg': true,
      'preparationTime': 5,
      'rating': 4.7,
    },
    {
      'id': 'item_4',
      'name': 'Masala Chai',
      'description': 'Indian spiced tea',
      'price': 30.0,
      'category': 'Beverages',
      'imageUrl': 'https://via.placeholder.com/300',
      'isAvailable': true,
      'isVeg': true,
      'preparationTime': 5,
      'rating': 4.8,
    },
  ];

  for (final item in menuItems) {
    await firestore.collection('menuItems').doc(item['id'] as String).set({
      ...item,
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('✅ Created menu item: ${item['name']}');
  }
}

/// Main setup function
Future<void> setupFirebaseData() async {
  try {
    print('🚀 Starting Firebase setup...\n');

    await setupRestaurantData();
    await setupAccessCodes();
    await setupMenuItems();

    print('\n✨ Firebase setup completed successfully!');
    print('\n📋 Test URLs you can use:');
    print('   • Valid: /demo_restaurant/TBL_1');
    print('   • Inactive table: /demo_restaurant/TBL_2');
    print('   • Invalid table: /demo_restaurant/FAKE_TABLE');
    print('   • Invalid restaurant: /fake_restaurant/TBL_1');
    print('   • Parcel order: /demo_restaurant/PARCEL_01');
    print('   • Restaurant only: /demo_restaurant');
    print('   • Cafe: /test_cafe/CAFE_TBL_1');
  } catch (e) {
    print('❌ Error during setup: $e');
    rethrow;
  }
}

/// Test data validation
Future<void> validateFirebaseData() async {
  final firestore = FirebaseFirestore.instance;

  print('\n🔍 Validating Firebase data...\n');

  // Check restaurants
  final restaurantsSnapshot = await firestore.collection('restaurants').get();
  print('📊 Restaurants count: ${restaurantsSnapshot.docs.length}');

  // Check access codes
  final accessCodesSnapshot = await firestore.collection('accessCodes').get();
  print('📊 Access codes count: ${accessCodesSnapshot.docs.length}');

  // Check menu items
  final menuItemsSnapshot = await firestore.collection('menuItems').get();
  print('📊 Menu items count: ${menuItemsSnapshot.docs.length}');

  // Validate specific documents
  final demoRestaurant = await firestore.collection('restaurants').doc('demo_restaurant').get();
  if (demoRestaurant.exists) {
    final data = demoRestaurant.data()!;
    print('\n✅ Demo Restaurant:');
    print('   Name: ${data['name']}');
    print('   Active: ${data['isActive']}');
  }

  final table1 = await firestore.collection('accessCodes').doc('TBL_1').get();
  if (table1.exists) {
    final data = table1.data()!;
    print('\n✅ Table TBL_1:');
    print('   Type: ${data['type']}');
    print('   Active: ${data['isActive']}');
    print('   Restaurant: ${data['restaurantId']}');
  }

  print('\n✅ Validation completed!');
}

/// Clean up all test data
Future<void> cleanupFirebaseData() async {
  final firestore = FirebaseFirestore.instance;

  print('🧹 Cleaning up Firebase data...\n');

  // Delete restaurants
  final restaurants = ['demo_restaurant', 'test_cafe', 'closed_restaurant'];
  for (final id in restaurants) {
    await firestore.collection('restaurants').doc(id).delete();
    print('🗑️ Deleted restaurant: $id');
  }

  // Delete access codes
  final accessCodes = [
    'TBL_1', 'TBL_2', 'TBL_3', 'TBL_4', 'TBL_5',
    'PARCEL_01', 'PARCEL_02', 'PARCEL_03',
    'CAFE_TBL_1',
  ];
  for (final code in accessCodes) {
    await firestore.collection('accessCodes').doc(code).delete();
    print('🗑️ Deleted access code: $code');
  }

  // Delete menu items
  final menuItems = ['item_1', 'item_2', 'item_3', 'item_4'];
  for (final id in menuItems) {
    await firestore.collection('menuItems').doc(id).delete();
    print('🗑️ Deleted menu item: $id');
  }

  print('\n✨ Cleanup completed!');
}

// Example usage in your app:
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Setup data
  await setupFirebaseData();

  // Validate data
  await validateFirebaseData();

  // When you're done testing:
  // await cleanupFirebaseData();

  runApp(MyApp());
}
*/

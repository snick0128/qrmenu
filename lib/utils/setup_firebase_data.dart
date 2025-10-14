import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

/// Add this function and call it once to set up your Firebase data
/// You can call this from anywhere in your app, like a button press
Future<void> setupURLRoutingData() async {
  try {
    print('\n📋 Setting up URL routing data...\n');

    final firestore = FirebaseFirestore.instance;

    // 1. Create demo_restaurant
    print('🏪 Creating restaurant: demo_restaurant');
    await firestore.collection('restaurants').doc('demo_restaurant').set({
      'id': 'demo_restaurant',
      'name': 'Demo Restaurant',
      'address': '123 Main Street, City, State 12345',
      'phone': '+1234567890',
      'logoUrl': 'https://via.placeholder.com/150',
      'isActive': true,
      'settings': {'currency': 'INR', 'taxRate': 5.0, 'serviceCharge': 10.0},
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('✅ Restaurant created: demo_restaurant\n');

    // 2. Create table access codes (dine-in)
    print('🍽️ Creating table access codes...');
    final tableCodes = ['TBL_1', 'TBL_2', 'TBL_3', 'TBL_4', 'TBL_5'];

    for (int i = 0; i < tableCodes.length; i++) {
      final code = tableCodes[i];
      final isActive = i != 1; // TBL_2 will be inactive for testing

      await firestore.collection('accessCodes').doc(code).set({
        'code': code,
        'type': 'dine_in',
        'tableNumber': 'Table ${i + 1}',
        'isActive': isActive,
        'restaurantId': 'demo_restaurant',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('  ✅ ${isActive ? "Active" : "Inactive"} table code: $code');
    }

    // 3. Create parcel access codes
    print('\n📦 Creating parcel access codes...');
    final parcelCodes = ['PARCEL_1', 'PARCEL_2', 'PARCEL_3'];

    for (final code in parcelCodes) {
      await firestore.collection('accessCodes').doc(code).set({
        'code': code,
        'type': 'parcel',
        'tableNumber': null,
        'isActive': true,
        'restaurantId': 'demo_restaurant',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('  ✅ Parcel code: $code');
    }

    print('\n═══════════════════════════════════════════════════════');
    print('🎉 Setup complete!');
    print('═══════════════════════════════════════════════════════\n');

    print('📱 Now test these URLs:\n');
    print('  ✅ http://localhost:PORT/demo_restaurant/tbl_1');
    print('  ✅ http://localhost:PORT/demo_restaurant/parcel_1');
    print('═══════════════════════════════════════════════════════\n');
  } catch (e) {
    print('❌ Error setting up data: $e');
    rethrow;
  }
}

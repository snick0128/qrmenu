import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qrmenu/core/firebase/firebase_service.dart';
import 'lib/firebase_options.dart';

/// Script to set up restaurant and access code data for URL routing
/// Run this with: dart setup_url_routing_data.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔥 Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await FirebaseService.initialize();
  
  print('\n📋 Setting up URL routing data...\n');
  
  try {
    // 1. Create demo_restaurant
    print('🏪 Creating restaurant: demo_restaurant');
    await FirebaseService.restaurants.doc('demo_restaurant').set({
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
    print('✅ Restaurant created: demo_restaurant\n');

    // 2. Create table access codes (dine-in)
    print('🍽️ Creating table access codes...');
    final tableCodes = ['TBL_1', 'TBL_2', 'TBL_3', 'TBL_4', 'TBL_5'];
    
    for (int i = 0; i < tableCodes.length; i++) {
      final code = tableCodes[i];
      final isActive = i != 1; // TBL_2 will be inactive for testing
      
      await FirebaseService.accessCodes.doc(code).set({
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
      await FirebaseService.accessCodes.doc(code).set({
        'code': code,
        'type': 'parcel',
        'tableNumber': null,
        'isActive': true,
        'restaurantId': 'demo_restaurant',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('  ✅ Parcel code: $code');
    }

    // 4. Create another restaurant for testing
    print('\n🏪 Creating restaurant: test_cafe');
    await FirebaseService.restaurants.doc('test_cafe').set({
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
    print('✅ Restaurant created: test_cafe\n');

    // 5. Create cafe table
    await FirebaseService.accessCodes.doc('CAFE_TBL_1').set({
      'code': 'CAFE_TBL_1',
      'type': 'dine_in',
      'tableNumber': 'Cafe Table 1',
      'isActive': true,
      'restaurantId': 'test_cafe',
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('  ✅ Cafe table code: CAFE_TBL_1\n');

    print('═══════════════════════════════════════════════════════');
    print('🎉 Setup complete! Data has been added to Firebase.');
    print('═══════════════════════════════════════════════════════\n');
    
    print('📱 Test these URLs in your browser:\n');
    print('  ✅ Valid dine-in:');
    print('     http://localhost:PORT/demo_restaurant/tbl_1');
    print('     http://localhost:PORT/demo_restaurant/TBL_1\n');
    
    print('  ✅ Valid parcel:');
    print('     http://localhost:PORT/demo_restaurant/parcel_1');
    print('     http://localhost:PORT/demo_restaurant/PARCEL_1\n');
    
    print('  ⚠️  Inactive table (should show manual entry):');
    print('     http://localhost:PORT/demo_restaurant/tbl_2\n');
    
    print('  ❌ Invalid table (should show manual entry):');
    print('     http://localhost:PORT/demo_restaurant/FAKE_TABLE\n');
    
    print('  ❌ Invalid restaurant (should show error):');
    print('     http://localhost:PORT/fake_restaurant/tbl_1\n');
    
    print('  ✅ Restaurant only (should show manual entry):');
    print('     http://localhost:PORT/demo_restaurant\n');
    
    print('  ✅ Test cafe:');
    print('     http://localhost:PORT/test_cafe/CAFE_TBL_1\n');
    
    print('═══════════════════════════════════════════════════════');
    print('💡 Tip: Check the Flutter console for debug logs like:');
    print('    🔍 URL Params - Restaurant: ..., Table Code: ...');
    print('    ✅ Restaurant found: ...');
    print('    ✅ Valid table code! Navigating to menu...');
    print('═══════════════════════════════════════════════════════\n');
    
  } catch (e) {
    print('❌ Error setting up data: $e');
    print('Stack trace: ${StackTrace.current}');
  }
}

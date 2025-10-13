import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/services/firebase_service.dart';
import 'lib/firebase_options.dart';

/// Script to add sample menu data to Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔥 Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await FirebaseService.initialize();
  
  print('📋 Adding sample menu data...');
  
  try {
    // Sample menu items
    final sampleMenuItems = [
      {
        'name': 'Vegetable Spring Rolls',
        'description': 'Crispy golden rolls filled with fresh vegetables, served with sweet chili sauce',
        'price': 180.0,
        'category': 'Appetizers',
        'imageUrl': '',
        'isVeg': true,
        'isSpicy': false,
        'isAvailable': true,
        'rating': 4.5,
        'reviewCount': 23,
        'allergens': [],
        'nutritionalInfo': {},
        'isPopular': true,
        'isQuickOrder': false,
        'preparationTime': '10-15 min',
      },
      {
        'name': 'Chicken Wings',
        'description': 'Spicy buffalo wings with blue cheese dip and celery sticks',
        'price': 280.0,
        'category': 'Appetizers',
        'imageUrl': '',
        'isVeg': false,
        'isSpicy': true,
        'isAvailable': true,
        'rating': 4.8,
        'reviewCount': 45,
        'allergens': ['dairy'],
        'nutritionalInfo': {},
        'isPopular': true,
        'isQuickOrder': false,
        'preparationTime': '15-20 min',
      },
      {
        'name': 'Butter Chicken',
        'description': 'Tender chicken pieces in rich, creamy tomato-based curry',
        'price': 420.0,
        'category': 'Main Course',
        'imageUrl': '',
        'isVeg': false,
        'isSpicy': false,
        'isAvailable': true,
        'rating': 4.9,
        'reviewCount': 67,
        'allergens': ['dairy'],
        'nutritionalInfo': {},
        'isPopular': true,
        'isQuickOrder': false,
        'preparationTime': '20-25 min',
      },
      {
        'name': 'Paneer Tikka Masala',
        'description': 'Grilled cottage cheese cubes in spiced onion-tomato gravy',
        'price': 380.0,
        'category': 'Main Course',
        'imageUrl': '',
        'isVeg': true,
        'isSpicy': true,
        'isAvailable': true,
        'rating': 4.6,
        'reviewCount': 34,
        'allergens': ['dairy'],
        'nutritionalInfo': {},
        'isPopular': false,
        'isQuickOrder': true,
        'preparationTime': '18-22 min',
      },
      {
        'name': 'Gulab Jamun',
        'description': 'Traditional milk dumplings soaked in rose-flavored sugar syrup',
        'price': 120.0,
        'category': 'Desserts',
        'imageUrl': '',
        'isVeg': true,
        'isSpicy': false,
        'isAvailable': true,
        'rating': 4.7,
        'reviewCount': 28,
        'allergens': ['dairy', 'nuts'],
        'nutritionalInfo': {},
        'isPopular': true,
        'isQuickOrder': true,
        'preparationTime': '5-8 min',
      },
      {
        'name': 'Chocolate Brownie',
        'description': 'Rich chocolate brownie with vanilla ice cream and chocolate sauce',
        'price': 180.0,
        'category': 'Desserts',
        'imageUrl': '',
        'isVeg': true,
        'isSpicy': false,
        'isAvailable': true,
        'rating': 4.4,
        'reviewCount': 19,
        'allergens': ['dairy', 'gluten'],
        'nutritionalInfo': {},
        'isPopular': false,
        'isQuickOrder': false,
        'preparationTime': '8-12 min',
      },
      {
        'name': 'Fresh Lime Soda',
        'description': 'Refreshing lime juice with soda water and mint',
        'price': 80.0,
        'category': 'Beverages',
        'imageUrl': '',
        'isVeg': true,
        'isSpicy': false,
        'isAvailable': true,
        'rating': 4.2,
        'reviewCount': 15,
        'allergens': [],
        'nutritionalInfo': {},
        'isPopular': false,
        'isQuickOrder': true,
        'preparationTime': '3-5 min',
      },
      {
        'name': 'Mango Lassi',
        'description': 'Creamy yogurt drink blended with sweet mango pulp',
        'price': 120.0,
        'category': 'Beverages',
        'imageUrl': '',
        'isVeg': true,
        'isSpicy': false,
        'isAvailable': true,
        'rating': 4.8,
        'reviewCount': 42,
        'allergens': ['dairy'],
        'nutritionalInfo': {},
        'isPopular': true,
        'isQuickOrder': true,
        'preparationTime': '5-7 min',
      },
    ];

    // Add menu items to Firebase
    for (var item in sampleMenuItems) {
      await FirebaseService.menuItems.add(item);
      print('✅ Added: ${item['name']}');
    }

    // Initialize some tables
    print('🍽️ Initializing tables...');
    for (int i = 1; i <= 12; i++) {
      await FirebaseService.firestore.collection('tables').doc('table_$i').set({
        'name': 'Table $i',
        'number': i,
        'capacity': i <= 6 ? 4 : (i <= 10 ? 6 : 8),
        'status': 'vacant',
        'sessionId': null,
        'reservedBy': null,
        'currentTotal': 0.0,
        'reservedAt': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
    
    print('✅ Tables initialized');
    print('🎉 Sample data setup complete!');
    print('');
    print('📱 Now run the admin app:');
    print('   flutter run lib/admin_main.dart');
    
  } catch (e) {
    print('❌ Error setting up sample data: $e');
  }
}
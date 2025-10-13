import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class SeedService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seeds all demo data including menu items, categories, access codes, and restaurants
  static Future<void> seedAllDemoData() async {
    try {
      print('🌱 Starting demo data seeding...');
      
      await _seedCategories();
      await _seedMenuItems();
      await _seedAccessCodes();
      await _seedRestaurantData();
      
      print('✅ Demo data seeded successfully!');
    } catch (e) {
      print('❌ Error seeding demo data: $e');
      rethrow;
    }
  }

  /// Seeds menu categories
  static Future<void> _seedCategories() async {
    print('📂 Seeding categories...');
    
    final categories = [
      {
        'id': 'appetizers',
        'name': 'Appetizers',
        'description': 'Start your meal right',
        'imageUrl': 'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Appetizers',
        'displayOrder': 1,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'mains',
        'name': 'Main Course',
        'description': 'Hearty and satisfying dishes',
        'imageUrl': 'https://via.placeholder.com/300x200/FF9800/FFFFFF?text=Mains',
        'displayOrder': 2,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'desserts',
        'name': 'Desserts',
        'description': 'Sweet endings',
        'imageUrl': 'https://via.placeholder.com/300x200/E91E63/FFFFFF?text=Desserts',
        'displayOrder': 3,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'beverages',
        'name': 'Beverages',
        'description': 'Refresh yourself',
        'imageUrl': 'https://via.placeholder.com/300x200/2196F3/FFFFFF?text=Beverages',
        'displayOrder': 4,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    final batch = _firestore.batch();
    
    for (final category in categories) {
      final docRef = FirebaseService.categories.doc(category['id'] as String);
      batch.set(docRef, category);
    }
    
    await batch.commit();
    print('✅ Categories seeded');
  }

  /// Seeds menu items
  static Future<void> _seedMenuItems() async {
    print('🍽️ Seeding menu items...');
    
    final menuItems = [
      // Appetizers
      {
        'id': 'app_1',
        'categoryId': 'appetizers',
        'name': 'Crispy Spring Rolls',
        'description': 'Fresh vegetables wrapped in crispy golden pastry, served with sweet chili sauce',
        'price': 180.0,
        'imageUrl': 'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Spring+Rolls',
        'isVeg': true,
        'isSpicy': false,
        'isPopular': true,
        'isQuickOrder': true,
        'isAvailable': true,
        'preparationTime': 15,
        'rating': 4.5,
        'tags': ['crispy', 'fresh', 'light'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'app_2',
        'categoryId': 'appetizers',
        'name': 'Chicken Wings',
        'description': 'Spicy buffalo wings with blue cheese dip and celery sticks',
        'price': 220.0,
        'imageUrl': 'https://via.placeholder.com/400x300/FF5722/FFFFFF?text=Chicken+Wings',
        'isVeg': false,
        'isSpicy': true,
        'isPopular': true,
        'isQuickOrder': false,
        'isAvailable': true,
        'preparationTime': 20,
        'rating': 4.7,
        'tags': ['spicy', 'buffalo', 'wings'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'app_3',
        'categoryId': 'appetizers',
        'name': 'Paneer Tikka',
        'description': 'Grilled cottage cheese marinated in aromatic spices and herbs',
        'price': 200.0,
        'imageUrl': 'https://via.placeholder.com/400x300/FF9800/FFFFFF?text=Paneer+Tikka',
        'isVeg': true,
        'isSpicy': true,
        'isPopular': false,
        'isQuickOrder': true,
        'isAvailable': true,
        'preparationTime': 18,
        'rating': 4.3,
        'tags': ['grilled', 'marinated', 'paneer'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      
      // Main Course
      {
        'id': 'main_1',
        'categoryId': 'mains',
        'name': 'Butter Chicken',
        'description': 'Tender chicken in rich tomato and cream sauce, served with basmati rice',
        'price': 350.0,
        'imageUrl': 'https://via.placeholder.com/400x300/FF9800/FFFFFF?text=Butter+Chicken',
        'isVeg': false,
        'isSpicy': false,
        'isPopular': true,
        'isQuickOrder': false,
        'isAvailable': true,
        'preparationTime': 25,
        'rating': 4.8,
        'tags': ['creamy', 'mild', 'popular'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'main_2',
        'categoryId': 'mains',
        'name': 'Margherita Pizza',
        'description': 'Classic pizza with fresh tomatoes, mozzarella, and basil on thin crust',
        'price': 280.0,
        'imageUrl': 'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Margherita',
        'isVeg': true,
        'isSpicy': false,
        'isPopular': true,
        'isQuickOrder': true,
        'isAvailable': true,
        'preparationTime': 20,
        'rating': 4.6,
        'tags': ['classic', 'italian', 'cheese'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'main_3',
        'categoryId': 'mains',
        'name': 'Vegetable Biryani',
        'description': 'Fragrant basmati rice cooked with mixed vegetables and aromatic spices',
        'price': 250.0,
        'imageUrl': 'https://via.placeholder.com/400x300/FF9800/FFFFFF?text=Veg+Biryani',
        'isVeg': true,
        'isSpicy': true,
        'isPopular': false,
        'isQuickOrder': false,
        'isAvailable': true,
        'preparationTime': 30,
        'rating': 4.4,
        'tags': ['aromatic', 'spiced', 'rice'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'main_4',
        'categoryId': 'mains',
        'name': 'Grilled Salmon',
        'description': 'Fresh Atlantic salmon grilled to perfection with lemon butter sauce',
        'price': 450.0,
        'imageUrl': 'https://via.placeholder.com/400x300/FF5722/FFFFFF?text=Grilled+Salmon',
        'isVeg': false,
        'isSpicy': false,
        'isPopular': false,
        'isQuickOrder': false,
        'isAvailable': true,
        'preparationTime': 22,
        'rating': 4.5,
        'tags': ['healthy', 'grilled', 'premium'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      
      // Desserts
      {
        'id': 'dess_1',
        'categoryId': 'desserts',
        'name': 'Chocolate Lava Cake',
        'description': 'Warm chocolate cake with molten center, served with vanilla ice cream',
        'price': 180.0,
        'imageUrl': 'https://via.placeholder.com/400x300/795548/FFFFFF?text=Lava+Cake',
        'isVeg': true,
        'isSpicy': false,
        'isPopular': true,
        'isQuickOrder': false,
        'isAvailable': true,
        'preparationTime': 12,
        'rating': 4.7,
        'tags': ['chocolate', 'warm', 'indulgent'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'dess_2',
        'categoryId': 'desserts',
        'name': 'Gulab Jamun',
        'description': 'Traditional Indian sweet dumplings in cardamom-rose syrup',
        'price': 120.0,
        'imageUrl': 'https://via.placeholder.com/400x300/FF9800/FFFFFF?text=Gulab+Jamun',
        'isVeg': true,
        'isSpicy': false,
        'isPopular': false,
        'isQuickOrder': true,
        'isAvailable': true,
        'preparationTime': 5,
        'rating': 4.2,
        'tags': ['traditional', 'sweet', 'syrup'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      
      // Beverages
      {
        'id': 'bev_1',
        'categoryId': 'beverages',
        'name': 'Fresh Lime Soda',
        'description': 'Refreshing lime juice with soda water and mint leaves',
        'price': 80.0,
        'imageUrl': 'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Lime+Soda',
        'isVeg': true,
        'isSpicy': false,
        'isPopular': false,
        'isQuickOrder': true,
        'isAvailable': true,
        'preparationTime': 3,
        'rating': 4.1,
        'tags': ['refreshing', 'citrus', 'mint'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'bev_2',
        'categoryId': 'beverages',
        'name': 'Masala Chai',
        'description': 'Traditional spiced Indian tea with cardamom, ginger, and cinnamon',
        'price': 60.0,
        'imageUrl': 'https://via.placeholder.com/400x300/795548/FFFFFF?text=Masala+Chai',
        'isVeg': true,
        'isSpicy': true,
        'isPopular': true,
        'isQuickOrder': true,
        'isAvailable': true,
        'preparationTime': 5,
        'rating': 4.6,
        'tags': ['spiced', 'traditional', 'warming'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'bev_3',
        'categoryId': 'beverages',
        'name': 'Fresh Orange Juice',
        'description': 'Freshly squeezed orange juice with pulp',
        'price': 90.0,
        'imageUrl': 'https://via.placeholder.com/400x300/FF9800/FFFFFF?text=Orange+Juice',
        'isVeg': true,
        'isSpicy': false,
        'isPopular': false,
        'isQuickOrder': true,
        'isAvailable': true,
        'preparationTime': 2,
        'rating': 4.3,
        'tags': ['fresh', 'citrus', 'vitamin-c'],
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    final batch = _firestore.batch();
    
    for (final item in menuItems) {
      final docRef = FirebaseService.menuItems.doc(item['id'] as String);
      batch.set(docRef, item);
    }
    
    await batch.commit();
    print('✅ Menu items seeded');
  }

  /// Seeds access codes for QR functionality
  static Future<void> _seedAccessCodes() async {
    print('🔑 Seeding access codes...');
    
    final accessCodes = [
      // Demo code for quick testing
      {
        'type': 'demo',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': null,
        'description': 'Demo code for testing both flows'
      },
      
      // Dine-in table codes
      {
        'type': 'dine_in',
        'tableNumber': '1',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': null,
        'description': 'Table 1 - Window side'
      },
      {
        'type': 'dine_in',
        'tableNumber': '2',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': null,
        'description': 'Table 2 - Corner table'
      },
      {
        'type': 'dine_in',
        'tableNumber': '3',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': null,
        'description': 'Table 3 - Center hall'
      },
      {
        'type': 'dine_in',
        'tableNumber': '4',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': null,
        'description': 'Table 4 - Near kitchen'
      },
      
      // Parcel codes
      {
        'type': 'parcel',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': null,
        'description': 'Parcel counter 1'
      },
      {
        'type': 'parcel',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': null,
        'description': 'Parcel counter 2'
      },
    ];

    final codeNames = [
      'DEMO',
      'TBL_1',
      'TBL_2', 
      'TBL_3',
      'TBL_4',
      'PARCEL_1',
      'PARCEL_2',
    ];

    final batch = _firestore.batch();
    
    for (int i = 0; i < accessCodes.length; i++) {
      final docRef = FirebaseService.accessCodes.doc(codeNames[i]);
      batch.set(docRef, accessCodes[i]);
    }
    
    await batch.commit();
    print('✅ Access codes seeded');
  }

  /// Seeds restaurant data
  static Future<void> _seedRestaurantData() async {
    print('🏪 Seeding restaurant data...');
    
    final restaurantData = {
      'id': 'demo_restaurant',
      'name': 'The Golden Fork',
      'description': 'Premium dining experience with authentic flavors and modern ambiance',
      'address': '123 Gourmet Street, Food District, Foodie City - 400001',
      'phoneNumber': '+91 98765 43210',
      'email': 'hello@goldenfork.com',
      'website': 'https://goldenfork.com',
      'imageUrl': 'https://via.placeholder.com/600x400/D4AF37/000000?text=The+Golden+Fork',
      'coverImageUrl': 'https://via.placeholder.com/1200x400/D4AF37/000000?text=Restaurant+Cover',
      'rating': 4.5,
      'totalReviews': 1247,
      'priceRange': '₹₹₹',
      'cuisine': ['Indian', 'Continental', 'Italian'],
      'features': ['Dine-in', 'Takeaway', 'Online Ordering', 'Live Music'],
      'openingHours': {
        'monday': {'open': '11:00', 'close': '23:00', 'isOpen': true},
        'tuesday': {'open': '11:00', 'close': '23:00', 'isOpen': true},
        'wednesday': {'open': '11:00', 'close': '23:00', 'isOpen': true},
        'thursday': {'open': '11:00', 'close': '23:00', 'isOpen': true},
        'friday': {'open': '11:00', 'close': '24:00', 'isOpen': true},
        'saturday': {'open': '10:00', 'close': '24:00', 'isOpen': true},
        'sunday': {'open': '10:00', 'close': '23:00', 'isOpen': true},
      },
      'socialMedia': {
        'instagram': '@goldenfork',
        'facebook': 'TheGoldenForkRestaurant',
        'twitter': '@goldenfork'
      },
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('restaurants').doc('demo_restaurant').set(restaurantData);
    print('✅ Restaurant data seeded');
  }

  /// Clears all demo data (use with caution)
  static Future<void> clearAllDemoData() async {
    print('🗑️ Clearing all demo data...');
    
    try {
      // Clear collections in batches
      await _clearCollection('categories');
      await _clearCollection('menuItems');
      await _clearCollection('accessCodes');
      await _clearCollection('restaurants');
      await _clearCollection('orders');
      await _clearCollection('dineInSessions');
      await _clearCollection('tableReservations');
      
      print('✅ All demo data cleared');
    } catch (e) {
      print('❌ Error clearing demo data: $e');
      rethrow;
    }
  }

  static Future<void> _clearCollection(String collectionName) async {
    final collection = _firestore.collection(collectionName);
    final snapshots = await collection.get();
    
    final batch = _firestore.batch();
    for (final doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    print('✅ Cleared $collectionName (${snapshots.docs.length} documents)');
  }

  /// Quick seed for development - only essential data
  static Future<void> seedQuickDemo() async {
    try {
      print('⚡ Quick seeding essential demo data...');
      
      // Seed minimal access codes
      final batch = _firestore.batch();
      
      // Demo code
      batch.set(FirebaseService.accessCodes.doc('DEMO'), {
        'type': 'demo',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'description': 'Quick demo code'
      });
      
      // One table code
      batch.set(FirebaseService.accessCodes.doc('TBL_1'), {
        'type': 'dine_in',
        'tableNumber': '1',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'description': 'Table 1'
      });
      
      // One parcel code
      batch.set(FirebaseService.accessCodes.doc('PARCEL_1'), {
        'type': 'parcel',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'description': 'Parcel counter'
      });
      
      await batch.commit();
      
      // Seed basic categories and items
      await _seedBasicCategoriesAndItems();
      
      print('✅ Quick demo data seeded!');
    } catch (e) {
      print('❌ Error in quick seeding: $e');
      rethrow;
    }
  }

  static Future<void> _seedBasicCategoriesAndItems() async {
    final batch = _firestore.batch();
    
    // Basic categories
    batch.set(FirebaseService.categories.doc('mains'), {
      'id': 'mains',
      'name': 'Main Course',
      'description': 'Hearty meals',
      'displayOrder': 1,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    batch.set(FirebaseService.categories.doc('beverages'), {
      'id': 'beverages',
      'name': 'Beverages',
      'description': 'Refreshing drinks',
      'displayOrder': 2,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Basic menu items
    batch.set(FirebaseService.menuItems.doc('pizza'), {
      'id': 'pizza',
      'categoryId': 'mains',
      'name': 'Margherita Pizza',
      'description': 'Classic pizza with cheese and tomatoes',
      'price': 280.0,
      'isVeg': true,
      'isSpicy': false,
      'isPopular': true,
      'isAvailable': true,
      'rating': 4.5,
      'preparationTime': 20,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    batch.set(FirebaseService.menuItems.doc('chai'), {
      'id': 'chai',
      'categoryId': 'beverages',
      'name': 'Masala Chai',
      'description': 'Traditional spiced tea',
      'price': 60.0,
      'isVeg': true,
      'isSpicy': true,
      'isPopular': true,
      'isAvailable': true,
      'rating': 4.6,
      'preparationTime': 5,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    await batch.commit();
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';
import '../utils/seed_data.dart' as local_seed;

/// Safe, idempotent Firebase seeder used for development/testing.
/// It will only create documents if they don't already exist.
class FirebaseSeeder {
  /// Ensures basic test data exists in Firestore: access codes (tables/parcel),
  /// menu items (from local seeded JSON) and a sample order for testing.
  static Future<void> seedIfAbsent() async {
    // Initialize Firebase (no-op if already initialized)
    await FirebaseService.initialize();

    final firestore = FirebaseService.firestore;

    // Seed access codes (TABLE1, TABLE2, PARCEL1)
    final accessCodes = firestore.collection('accessCodes');

    final codesToEnsure = [
      {
        'docId': 'TABLE1',
        'data': {
          'code': 'TABLE1',
          'type': 'dine_in',
          'tableNumber': '1',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'docId': 'TABLE2',
        'data': {
          'code': 'TABLE2',
          'type': 'dine_in',
          'tableNumber': '2',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'docId': 'PARCEL1',
        'data': {
          'code': 'PARCEL1',
          'type': 'parcel',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      },
    ];

    for (final entry in codesToEnsure) {
      final docId = entry['docId'] as String;
      final docRef = accessCodes.doc(docId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        await docRef.set(Map<String, dynamic>.from(entry['data'] as Map));
      }
    }

    // Seed menu items only if collection is empty (or has very few docs)
    final menuCol = firestore.collection('menuItems');
    final menuSnapshot = await menuCol.limit(1).get();
    if (menuSnapshot.docs.isEmpty) {
      // Load local seeded menu items
      final items = await local_seed.SeedData.loadMenuItems();

      for (final item in items) {
        // Use model's toJson if available; we saved menu JSON in the seeded file
        await menuCol.add(item.toJson());
      }
    }

    // Create a sample order (if none) to allow adding items to cart / test flow
    final ordersCol = firestore.collection('orders');
    final ordersSnapshot = await ordersCol.limit(1).get();
    if (ordersSnapshot.docs.isEmpty) {
      // Create a simple sample order with one seeded item (if available)
      final menuDocs = await menuCol.limit(1).get();
      Map<String, dynamic> sampleItem = {
        'name': 'Placeholder Item',
        'price': 10.0,
        'quantity': 1,
      };

      if (menuDocs.docs.isNotEmpty) {
        final doc = menuDocs.docs.first;
        final data = doc.data();
        sampleItem = {
          'menuItemId': doc.id,
          'name': data['name'] ?? 'Seeded Item',
          'price': (data['price'] is num)
              ? (data['price'] as num).toDouble()
              : 0.0,
          'quantity': 1,
        };
      }

      await ordersCol.add({
        'type': 'parcel',
        'items': [sampleItem],
        'totalAmount':
            (sampleItem['price'] ?? 0) * (sampleItem['quantity'] ?? 1),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

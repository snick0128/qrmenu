import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Use plain maps for seeding to avoid tight coupling with model constructors.

class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Generic fetch function. Optional [filters] is a map of field->value for
  /// simple equality filters.
  static Future<List<Map<String, dynamic>>> fetchData(
    String collectionPath, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      CollectionReference col = _db.collection(collectionPath);
      Query query = col;
      if (filters != null && filters.isNotEmpty) {
        filters.forEach((key, value) {
          query = query.where(key, isEqualTo: value);
        });
      }
      final snapshot = await query.get();
      return snapshot.docs
          .map((d) => {...d.data() as Map<String, dynamic>, 'id': d.id})
          .toList();
    } catch (e, st) {
      print('FirestoreService.fetchData($collectionPath) failed: $e');
      print(st);
      return <Map<String, dynamic>>[];
    }
  }

  static Future<DocumentReference?> addData(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    try {
      final ref = await _db.collection(collectionPath).add(data);
      print('FirestoreService.addData: added to $collectionPath/${ref.id}');
      return ref;
    } catch (e, st) {
      print('FirestoreService.addData($collectionPath) failed: $e');
      print(st);
      return null;
    }
  }

  static Future<bool> updateData(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection(collectionPath).doc(docId).update(data);
      print('FirestoreService.updateData: updated $collectionPath/$docId');
      return true;
    } catch (e, st) {
      print('FirestoreService.updateData($collectionPath/$docId) failed: $e');
      print(st);
      return false;
    }
  }

  static Future<bool> deleteData(String collectionPath, String docId) async {
    try {
      await _db.collection(collectionPath).doc(docId).delete();
      print('FirestoreService.deleteData: deleted $collectionPath/$docId');
      return true;
    } catch (e, st) {
      print('FirestoreService.deleteData($collectionPath/$docId) failed: $e');
      print(st);
      return false;
    }
  }

  /// Debug-only seeding: creates a couple restaurants, categories and menu items.
  static Future<void> seedDemoData() async {
    if (!kDebugMode) {
      print('FirestoreService.seedDemoData: skipped (not in debug mode)');
      return;
    }

    try {
      print('FirestoreService.seedDemoData: starting');

      // Example structure: restaurants -> categories subcollection -> menuItems
      final restaurants = [
        {
          'name': 'Demo Diner',
          'address': '123 Demo St',
          'phone': '000-000-0000',
          'logoUrl': 'https://via.placeholder.com/100',
          'settings': {},
        },
        {
          'name': 'Sample Cafe',
          'address': '456 Sample Ave',
          'phone': '111-111-1111',
          'logoUrl': 'https://via.placeholder.com/100',
          'settings': {},
        },
      ];

      for (final r in restaurants) {
        final docRef = await addData('restaurants', r);
        if (docRef == null) continue;

        final categories = [
          {'name': 'Starters'},
          {'name': 'Mains'},
        ];

        for (final c in categories) {
          final catRef = await addData(
            'restaurants/${docRef.id}/categories',
            c,
          );
          if (catRef == null) continue;

          final items = [
            {
              'name': 'Sample Item A',
              'description': 'Tasty sample',
              'price': 4.99,
              'category': c['name'],
              'imageUrl': 'https://via.placeholder.com/150',
            },
            {
              'name': 'Sample Item B',
              'description': 'Another sample',
              'price': 7.50,
              'category': c['name'],
              'imageUrl': '',
            },
          ];

          for (final it in items) {
            await addData('restaurants/${docRef.id}/menuItems', it);
          }
        }
      }

      print('FirestoreService.seedDemoData: finished');
    } catch (e, st) {
      print('FirestoreService.seedDemoData failed: $e');
      print(st);
    }
  }

  /// Debug-only: clear demo data created under `restaurants` collection.
  /// WARNING: This deletes the whole `restaurants` collection documents.
  static Future<void> clearSeedData() async {
    if (!kDebugMode) {
      print('FirestoreService.clearSeedData: skipped (not in debug mode)');
      return;
    }

    try {
      print('FirestoreService.clearSeedData: starting');
      final snapshot = await _db.collection('restaurants').get();
      for (final doc in snapshot.docs) {
        // delete subcollections menuItems and categories first
        final menuSnapshot = await _db
            .collection('restaurants/${doc.id}/menuItems')
            .get();
        for (final m in menuSnapshot.docs) {
          await m.reference.delete();
        }

        final catSnapshot = await _db
            .collection('restaurants/${doc.id}/categories')
            .get();
        for (final c in catSnapshot.docs) {
          await c.reference.delete();
        }

        await doc.reference.delete();
      }

      print('FirestoreService.clearSeedData: finished');
    } catch (e, st) {
      print('FirestoreService.clearSeedData failed: $e');
      print(st);
    }
  }
}

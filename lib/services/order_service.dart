import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';
import 'firebase_service.dart';

class OrderService {
  // Create a new order
  static Future<String> createOrder({
    required String hotelId,
    required String tableNo,
    required String type,
    required List<CartItemModel> items,
    required double total,
    String? sessionId,
  }) async {
    try {
      // Reference to hotel's orders collection
      final orderRef = FirebaseService.restaurants
          .doc(hotelId)
          .collection('orders');

      // Create order document
      final orderDoc = await orderRef.add({
        'tableNo': tableNo,
        'type': type,
        'items': items
            .map(
              (item) => {
                'itemId': item.menuItem.id,
                'name': item.menuItem.name,
                'qty': item.quantity,
                'price': item.menuItem.price,
                'status': 'pending',
              },
            )
            .toList(),
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'sessionId': sessionId,
      });

      // Update analytics for each item
      for (final item in items) {
        await _incrementMostOrdered(item.menuItem, item.quantity);
      }

      // For dine-in orders, update the active order ID in the session
      if (type == 'dine_in' && sessionId != null) {
        await FirebaseService.dineInSessions.doc(sessionId).update({
          'activeOrderId': orderDoc.id,
        });
      }

      return orderDoc.id;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  // Get existing order for dine-in session
  static Future<String?> getDineInOrder(String sessionId) async {
    try {
      final sessionDoc = await FirebaseService.dineInSessions
          .doc(sessionId)
          .get();
      if (sessionDoc.exists) {
        final data = sessionDoc.data() as Map<String, dynamic>;
        return data['activeOrderId'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting dine-in order: $e');
      return null;
    }
  }

  // Stream order status updates
  static Stream<DocumentSnapshot> getOrderStream(
    String hotelId,
    String orderId,
  ) {
    return FirebaseService.restaurants
        .doc(hotelId)
        .collection('orders')
        .doc(orderId)
        .snapshots();
  }

  // Increment most ordered items counter
  static Future<void> _incrementMostOrdered(
    MenuItemModel item,
    int quantity,
  ) async {
    try {
      await FirebaseService.analytics
          .doc('mostOrdered')
          .collection('items')
          .doc(item.id)
          .set({
            'count': FieldValue.increment(quantity),
            'name': item.name,
            'category': item.category,
            'lastOrdered': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating most ordered: $e');
      // Don't throw - this is not critical
    }
  }
}

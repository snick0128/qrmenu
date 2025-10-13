import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/table_model.dart';
import '../models/sales_analytics.dart';
import '../models/order_model.dart';
import '../models/dining_session.dart';
import '../models/menu_item_model.dart';
import '../services/firebase_service.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;
  
  // Collection references
  static CollectionReference get tables => _firestore.collection('tables');
  static CollectionReference get analytics => _firestore.collection('analytics');
  
  // Initialize default tables (call once during setup)
  static Future<void> initializeTables() async {
    try {
      final tablesSnapshot = await tables.get();
      if (tablesSnapshot.docs.isEmpty) {
        // Create default tables
        for (int i = 1; i <= 20; i++) {
          await tables.doc('table_$i').set(TableModel(
            id: 'table_$i',
            name: 'Table $i',
            number: i,
            capacity: i <= 10 ? 4 : (i <= 15 ? 6 : 8),
          ).toJson());
        }
      }
    } catch (e) {
      print('Error initializing tables: $e');
    }
  }

  // Get all tables with real-time updates
  static Stream<List<TableModel>> getTablesStream() {
    return tables.orderBy('number').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TableModel.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  // Update table status
  static Future<void> updateTableStatus(String tableId, TableStatus status) async {
    try {
      await tables.doc(tableId).update({
        'status': status.toString(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating table status: $e');
      rethrow;
    }
  }

  // Reserve table for session
  static Future<void> reserveTableForSession(String tableId, String sessionId, String reservedBy) async {
    try {
      await tables.doc(tableId).update({
        'status': TableStatus.occupied.toString(),
        'sessionId': sessionId,
        'reservedBy': reservedBy,
        'reservedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error reserving table: $e');
      rethrow;
    }
  }

  // Update table total amount
  static Future<void> updateTableTotal(String tableId, double amount) async {
    try {
      await tables.doc(tableId).update({
        'currentTotal': amount,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating table total: $e');
    }
  }

  // Release table
  static Future<void> releaseTable(String tableId) async {
    try {
      await tables.doc(tableId).update({
        'status': TableStatus.vacant.toString(),
        'sessionId': null,
        'reservedBy': null,
        'currentTotal': 0,
        'reservedAt': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error releasing table: $e');
      rethrow;
    }
  }

  // Get sales analytics for different date ranges
  static Future<SalesAnalytics> getSalesAnalytics(DateFilterType dateFilter) async {
    try {
      DateTime startDate;
      DateTime endDate = DateTime.now();

      switch (dateFilter) {
        case DateFilterType.today:
          startDate = DateTime(endDate.year, endDate.month, endDate.day);
          break;
        case DateFilterType.week:
          startDate = endDate.subtract(const Duration(days: 7));
          break;
        case DateFilterType.month:
          startDate = DateTime(endDate.year, endDate.month, 1);
          break;
      }

      // Get orders within date range
      final ordersQuery = FirebaseService.orders
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      final ordersSnapshot = await ordersQuery.get();
      
      // Get dine-in sessions within date range
      final sessionsQuery = FirebaseService.dineInSessions
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      final sessionsSnapshot = await sessionsQuery.get();

      int totalOrders = ordersSnapshot.docs.length + sessionsSnapshot.docs.length;
      double totalSales = 0.0;
      int ongoingOrders = 0;
      int completedOrders = 0;
      int cancelledOrders = 0;

      // Process parcel orders
      for (var doc in ordersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String? ?? 'pending';
        final total = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;

        totalSales += total;

        if (status == 'completed') {
          completedOrders++;
        } else if (status == 'cancelled') {
          cancelledOrders++;
        } else {
          ongoingOrders++;
        }
      }

      // Process dine-in sessions
      for (var doc in sessionsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String? ?? 'active';
        final total = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;

        totalSales += total;

        if (status == 'completed') {
          completedOrders++;
        } else if (status == 'cancelled') {
          cancelledOrders++;
        } else {
          ongoingOrders++;
        }
      }

      double averageOrderValue = totalOrders > 0 ? totalSales / totalOrders : 0.0;

      return SalesAnalytics(
        totalOrders: totalOrders,
        totalSales: totalSales,
        ongoingOrders: ongoingOrders,
        completedOrders: completedOrders,
        cancelledOrders: cancelledOrders,
        averageOrderValue: averageOrderValue,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('Error getting sales analytics: $e');
      return const SalesAnalytics();
    }
  }

  // Get real-time sales analytics stream
  static Stream<SalesAnalytics> getSalesAnalyticsStream(DateFilterType dateFilter) {
    return Stream.periodic(const Duration(seconds: 30)).asyncMap((_) async {
      return await getSalesAnalytics(dateFilter);
    });
  }

  // Get all orders with filters
  static Stream<List<Map<String, dynamic>>> getOrdersStream({String? statusFilter}) {
    Query ordersQuery = FirebaseService.orders.orderBy('createdAt', descending: true);
    
    if (statusFilter != null && statusFilter != 'all') {
      ordersQuery = ordersQuery.where('status', isEqualTo: statusFilter);
    }

    return ordersQuery.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
          'type': 'parcel',
        };
      }).toList();
    });
  }

  // Get all dine-in sessions
  static Stream<List<Map<String, dynamic>>> getDineInSessionsStream({String? statusFilter}) {
    Query sessionsQuery = FirebaseService.dineInSessions.orderBy('startTime', descending: true);
    
    if (statusFilter != null && statusFilter != 'all') {
      sessionsQuery = sessionsQuery.where('status', isEqualTo: statusFilter);
    }

    return sessionsQuery.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
          'type': 'dine_in',
        };
      }).toList();
    });
  }

  // Update item status in order/session
  static Future<void> updateItemStatus(String orderId, String orderType, int itemIndex, String status) async {
    try {
      final collection = orderType == 'dine_in' ? 
          FirebaseService.dineInSessions : FirebaseService.orders;
      
      final doc = await collection.doc(orderId).get();
      final data = doc.data() as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

      if (itemIndex < items.length) {
        items[itemIndex]['status'] = status;
        items[itemIndex]['statusUpdatedAt'] = FieldValue.serverTimestamp();
        items[itemIndex]['updatedBy'] = 'admin';

        await collection.doc(orderId).update({'items': items});
      }
    } catch (e) {
      print('Error updating item status: $e');
      rethrow;
    }
  }

  // Generate bill for session
  static Future<Map<String, dynamic>> generateBill(String sessionId, String sessionType) async {
    try {
      final collection = sessionType == 'dine_in' ? 
          FirebaseService.dineInSessions : FirebaseService.orders;
      
      final doc = await collection.doc(sessionId).get();
      final data = doc.data() as Map<String, dynamic>;

      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
      double subtotal = 0.0;

      for (var item in items) {
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        final quantity = (item['quantity'] as int?) ?? 1;
        subtotal += price * quantity;
      }

      const double taxRate = 0.18; // 18% GST
      final double tax = subtotal * taxRate;
      final double total = subtotal + tax;

      return {
        'sessionId': sessionId,
        'items': items,
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
        'taxRate': taxRate,
        'generatedAt': FieldValue.serverTimestamp(),
      };
    } catch (e) {
      print('Error generating bill: $e');
      rethrow;
    }
  }

  // Complete payment and close session
  static Future<void> completePayment(String sessionId, String sessionType, String paymentMethod) async {
    try {
      final collection = sessionType == 'dine_in' ? 
          FirebaseService.dineInSessions : FirebaseService.orders;
      
      await collection.doc(sessionId).update({
        'status': 'completed',
        'paymentStatus': 'paid',
        'paymentMethod': paymentMethod,
        'completedAt': FieldValue.serverTimestamp(),
      });

      // If dine-in, also release the table
      if (sessionType == 'dine_in') {
        final sessionDoc = await collection.doc(sessionId).get();
        final sessionData = sessionDoc.data() as Map<String, dynamic>;
        final tableNumber = sessionData['tableNumber'] as String?;
        
        if (tableNumber != null) {
          await releaseTable('table_$tableNumber');
        }
      }
    } catch (e) {
      print('Error completing payment: $e');
      rethrow;
    }
  }

  // Add item manually to session (by admin)
  static Future<void> addItemToSession(String sessionId, String sessionType, Map<String, dynamic> item) async {
    try {
      final itemWithAdminFlag = {
        ...item,
        'addedBy': 'admin',
        'status': 'pending',
        'addedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseService.addItemToSession(sessionId, itemWithAdminFlag, sessionType);
      
      // Update table total if dine-in
      if (sessionType == 'dine_in') {
        final sessionDoc = await FirebaseService.dineInSessions.doc(sessionId).get();
        final sessionData = sessionDoc.data() as Map<String, dynamic>;
        final tableNumber = sessionData['tableNumber'] as String?;
        final totalAmount = (sessionData['totalAmount'] as num?)?.toDouble() ?? 0.0;
        
        if (tableNumber != null) {
          await updateTableTotal('table_$tableNumber', totalAmount);
        }
      }
    } catch (e) {
      print('Error adding item to session: $e');
      rethrow;
    }
  }
}
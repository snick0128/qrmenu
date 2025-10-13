import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/code_validation.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  static FirebaseFirestore? _firestore;

  // Web-specific Firebase configuration
  static const _firebaseConfig = {
    'apiKey': "AIzaSyBmYs4vKozkwXJMAzMxVgJ-wqKqzGUx3tY",
    'authDomain': "qr-menu-a78e9.firebaseapp.com",
    'projectId': "qr-menu-a78e9",
    'storageBucket': "qr-menu-a78e9.firebasestorage.app",
    'messagingSenderId': "372121518713",
    'appId': "1:372121518713:web:6ac45d721bd4cc1d99caa8",
    'measurementId': "G-0M81DQEY9S",
  };

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  static Future<void> initialize() async {
    try {
      // Firebase Core is already initialized in main.dart
      // Just set up the Firestore instance
      _firestore = FirebaseFirestore.instance;

      // Optimize for web
      _firestore?.settings = const Settings(
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      print('FirebaseService: Firestore instance initialized');
    } catch (e) {
      print('Error initializing FirebaseService: $e');
      rethrow;
    }
  }

  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _firestore!;
  }

  // Collection References
  static CollectionReference get orders => firestore.collection('orders');
  static CollectionReference get dineInSessions =>
      firestore.collection('dineInSessions');
  static CollectionReference get menuItems => firestore.collection('menuItems');
  static CollectionReference get categories =>
      firestore.collection('categories');
  static CollectionReference get accessCodes =>
      firestore.collection('accessCodes');
  static CollectionReference get tableReservations =>
      firestore.collection('tableReservations');
  static CollectionReference get restaurants => firestore.collection('restaurants');

  // Debug method to list all access codes
  static Future<void> listAllAccessCodes() async {
    try {
      final snapshot = await accessCodes.get();
      print('Total access codes: ${snapshot.docs.length}');
      for (var doc in snapshot.docs) {
        print('Code: ${doc.id}, Data: ${doc.data()}');
      }
    } catch (e) {
      print('Error listing access codes: $e');
    }
  }

  static Future<Map<String, dynamic>?> validateHotelAndTable(String hotelId, String tableNumber) async {
    try {
      final restaurantDoc = await restaurants.doc(hotelId).get();
      if (!restaurantDoc.exists) {
        return null;
      }

      final tableDoc = await restaurants.doc(hotelId).collection('tables').doc(tableNumber).get();
      if (!tableDoc.exists) {
        return null;
      }

      return restaurantDoc.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error validating hotel and table: $e');
      return null;
    }
  }

  // Check table reservation status
  static Future<Map<String, dynamic>> checkTableReservation(String tableNumber) async {
    try {
      final reservationDoc = await tableReservations.doc(tableNumber).get();
      
      if (!reservationDoc.exists) {
        return {
          'isReserved': false,
          'reservedBy': null,
          'sessionId': null,
          'status': 'vacant'
        };
      }
      
      final data = reservationDoc.data() as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'occupied';

      return {
        'isReserved': status == 'occupied',
        'reservedBy': data['userId'],
        'sessionId': data['sessionId'],
        'status': status,
        'reservedAt': data['reservedAt'],
      };
    } catch (e) {
      print('Error checking table reservation: $e');
      return {
        'isReserved': false,
        'reservedBy': null,
        'sessionId': null,
        'status': 'error'
      };
    }
  }

  // Reserve table for dine-in session
  static Future<String> reserveTable(String tableNumber, String userId) async {
    try {
      // Check if table is already reserved
      final reservation = await checkTableReservation(tableNumber);
      if (reservation['isReserved'] && reservation['reservedBy'] != userId) {
        throw Exception('Table is already reserved by another guest');
      }
      
      // Create or update reservation
      final reservationData = {
        'tableNumber': tableNumber,
        'userId': userId,
        'status': 'occupied',
        'reservedAt': FieldValue.serverTimestamp(),
        'sessionId': null, // Will be updated when session is created
      };
      
      await tableReservations.doc(tableNumber).set(reservationData);
      
      // Create dine-in session
      final sessionRef = await dineInSessions.add({
        'userId': userId,
        'tableNumber': tableNumber,
        'status': 'active',
        'startTime': FieldValue.serverTimestamp(),
        'items': [],
        'totalAmount': 0,
        'paymentStatus': 'pending',
        'paymentMethod': null,
      });
      
      // Update reservation with session ID
      await tableReservations.doc(tableNumber).update({
        'sessionId': sessionRef.id,
      });
      
      return sessionRef.id;
    } catch (e) {
      print('Error reserving table: $e');
      rethrow;
    }
  }

  // Release table reservation
  static Future<void> releaseTableReservation(String tableNumber) async {
    try {
      await tableReservations.doc(tableNumber).update({
        'status': 'vacant',
        'vacantAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error releasing table reservation: $e');
    }
  }

  // Validate any code (QR or manual entry)
  static Future<CodeValidationResult> validateCode(String code) async {
    try {
      final normalizedCode = code.trim().toUpperCase();
      print('Validating code: $normalizedCode');

      // Check if code exists in access codes
      final codeDoc = await accessCodes.doc(normalizedCode).get();
      print('Document exists: ${codeDoc.exists}');

      if (!codeDoc.exists) {
        print('Code document not found');
        return CodeValidationResult(isValid: false, code: normalizedCode);
      }

      final data = codeDoc.data() as Map<String, dynamic>;
      print('Document data: $data');
      
      final isActive = data['isActive'] ?? false;
      print('Is active: $isActive');

      if (!isActive) {
        print('Code is not active');
        return CodeValidationResult(isValid: false, code: normalizedCode);
      }

      final type = data['type'] as String;
      final tableNumber = data['tableNumber'] as String?;
      print('Type: $type, Table: $tableNumber');

      return CodeValidationResult(
        isValid: true,
        sessionType: type,
        tableNumber: tableNumber,
        code: normalizedCode,
      );
    } catch (e) {
      print('Error validating code: $e');
      return CodeValidationResult(isValid: false, code: code);
    }
  }

  // Initialize session based on validated code
  static Future<String> initializeSession(
    String userId,
    CodeValidationResult validation,
  ) async {
    if (!validation.isValid) {
      throw Exception('Invalid code');
    }

    if (validation.isDineIn) {
      // Check table reservation for dine-in
      final reservation = await checkTableReservation(validation.tableNumber!);
      
      if (reservation['isReserved'] && reservation['reservedBy'] != userId) {
        throw Exception('Table is reserved by another guest');
      }
      
      if (reservation['isReserved'] && reservation['reservedBy'] == userId) {
        // Resume existing session
        return reservation['sessionId'] as String;
      }
      
      // Reserve table and create new session
      return await reserveTable(validation.tableNumber!, userId);
    } else {
      // Create parcel session
      final sessionRef = await orders.add({
        'userId': userId,
        'code': validation.code,
        'type': 'parcel',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'items': [],
        'totalAmount': 0,
        'paymentStatus': 'pending',
        'paymentMethod': null,
      });
      return sessionRef.id;
    }
  }

  // Create new dine-in session
  static Future<String> createDineInSession(String tableNumber) async {
    final session = await dineInSessions.add({
      'tableNumber': tableNumber,
      'startTime': FieldValue.serverTimestamp(),
      'status': 'active',
      'totalAmount': 0,
      'items': [],
    });
    return session.id;
  }

  // Add item to dine-in session
  static Future<void> addItemToDineInSession(
    String sessionId,
    Map<String, dynamic> item,
  ) async {
    await dineInSessions.doc(sessionId).update({
      'items': FieldValue.arrayUnion([item]),
      'totalAmount': FieldValue.increment(item['price'] * item['quantity']),
    });
  }

  // Create parcel order
  static Future<String> createParcelOrder(
    List<Map<String, dynamic>> items,
    double totalAmount,
  ) async {
    final order = await orders.add({
      'type': 'parcel',
      'items': items,
      'totalAmount': totalAmount,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return order.id;
  }

  // Update order status
  static Future<void> updateOrderStatus(String orderId, String status) async {
    await orders.doc(orderId).update({'status': status});
  }

  // Close dine-in session
  static Future<void> closeDineInSession(
    String sessionId,
    String paymentMethod,
  ) async {
    // Get session data to release table
    final sessionDoc = await dineInSessions.doc(sessionId).get();
    final sessionData = sessionDoc.data() as Map<String, dynamic>;
    final tableNumber = sessionData['tableNumber'] as String;
    
    // Update session
    await dineInSessions.doc(sessionId).update({
      'status': 'completed',
      'endTime': FieldValue.serverTimestamp(),
      'paymentMethod': paymentMethod,
      'paymentStatus': 'completed',
    });
    
    // Release table reservation
    await releaseTableReservation(tableNumber);
  }

  // Save review for a dine-in session
  static Future<void> saveReview(String sessionId, String name, [String? message]) async {
    try {
      await dineInSessions.doc(sessionId).update({
        'review': {
          'name': name,
          'message': message ?? '',
          'submittedAt': FieldValue.serverTimestamp(),
        }
      });
    } catch (e) {
      print('Error saving review: $e');
      rethrow;
    }
  }

  // Add item to session with status
  static Future<void> addItemToSession(
    String sessionId,
    Map<String, dynamic> item,
    String sessionType,
  ) async {
    final itemWithStatus = {
      ...item,
      'status': 'pending',
      'addedAt': FieldValue.serverTimestamp(),
    };
    
    if (sessionType == 'dine_in') {
      await dineInSessions.doc(sessionId).update({
        'items': FieldValue.arrayUnion([itemWithStatus]),
        'totalAmount': FieldValue.increment(item['price'] * item['quantity']),
      });
    } else {
      await orders.doc(sessionId).update({
        'items': FieldValue.arrayUnion([itemWithStatus]),
        'totalAmount': FieldValue.increment(item['price'] * item['quantity']),
      });
    }
  }

  // Update item status
  static Future<void> updateItemStatus(
    String sessionId,
    int itemIndex,
    String status,
    String sessionType,
  ) async {
    final collection = sessionType == 'dine_in' ? dineInSessions : orders;
    final sessionDoc = await collection.doc(sessionId).get();
    final sessionData = sessionDoc.data() as Map<String, dynamic>;
    final items = List<Map<String, dynamic>>.from(sessionData['items'] ?? []);
    
    if (itemIndex < items.length) {
      items[itemIndex]['status'] = status;
      items[itemIndex]['statusUpdatedAt'] = FieldValue.serverTimestamp();
      
      await collection.doc(sessionId).update({
        'items': items,
      });
    }
  }

  // Reorder served item (adds new pending item)
  static Future<void> reorderItem(
    String sessionId,
    Map<String, dynamic> servedItem,
    String sessionType,
  ) async {
    final newItem = {
      ...servedItem,
      'status': 'pending',
      'addedAt': FieldValue.serverTimestamp(),
      'isReorder': true,
    };
    
    await addItemToSession(sessionId, newItem, sessionType);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/guest_session.dart';

class SessionService {
  SessionService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Collection reference for guest sessions
  static final CollectionReference _sessions = _firestore.collection(
    'sessions',
  );

  /// Creates or updates a guest session in Firestore
  static Future<void> createOrUpdateGuestSession({
    required String hotelId,
    required String tableNo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final guestSession = GuestSession(
      guestUid: user.uid,
      hotelId: hotelId,
      tableNo: tableNo,
      createdAt: DateTime.now(),
    );

    await _sessions.doc(user.uid).set(guestSession.toJson());
  }

  /// Gets the current guest's active session
  static Future<GuestSession?> getCurrentSession() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final doc = await _sessions.doc(user.uid).get();
    if (!doc.exists) {
      return null;
    }

    return GuestSession.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Updates the active order ID for the current session
  static Future<void> updateActiveOrder(String orderId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    await _sessions.doc(user.uid).update({'activeOrderId': orderId});
  }

  /// Clears the active order ID from the current session
  static Future<void> clearActiveOrder() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    await _sessions.doc(user.uid).update({'activeOrderId': null});
  }

  /// Stream of session changes for the current user
  static Stream<GuestSession?> sessionStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    return _sessions.doc(user.uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return GuestSession.fromJson(doc.data() as Map<String, dynamic>);
    });
  }
}

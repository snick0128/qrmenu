import 'package:firebase_auth/firebase_auth.dart';

/// AuthService: handles Firebase Authentication with persistence support
class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize auth service and set persistence
  static Future<void> initialize() async {
    try {
      await _auth.setPersistence(Persistence.LOCAL);
      print('AuthService: persistence set to LOCAL');
    } catch (e, st) {
      print('AuthService: failed to set persistence: $e');
      print(st);
    }
  }

  /// Sign in anonymously as a guest. Returns the [User] on success or null on
  /// failure.
  static Future<User?> signInAsGuest() async {
    try {
      // Try to use existing anonymous user first
      User? user = _auth.currentUser;

      // If no existing user, create new anonymous account
      if (user == null) {
        final userCredential = await _auth.signInAnonymously();
        user = userCredential.user;
        print('AuthService: created new anonymous user, uid=${user?.uid}');
      } else {
        print('AuthService: using existing anonymous user, uid=${user.uid}');
      }
      return user;
    } catch (e, st) {
      print('AuthService: signInAsGuest failed: $e');
      print(st);
      return null;
    }
  }

  /// Sign out the current user.
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('AuthService: signed out');
    } catch (e, st) {
      print('AuthService: signOut failed: $e');
      print(st);
    }
  }

  /// Current Firebase user (may be null).
  static User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes (User? objects).
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}

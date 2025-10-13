import 'package:firebase_auth/firebase_auth.dart';

/// AuthService: lightweight wrapper around FirebaseAuth for anonymous guest
/// sign-in. All functions use async/await and handle errors with debug prints.
class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in anonymously as a guest. Returns the [User] on success or null on
  /// failure.
  static Future<User?> signInAsGuest() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;
      if (user != null) {
        print('AuthService: signed in anonymously, uid=${user.uid}');
      } else {
        print('AuthService: anonymous sign-in returned no user');
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

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Web configuration
    return const FirebaseOptions(
      apiKey: 'AIzaSyBmYs4vKozkwXJMAzMxVgJ-wqKqzGUx3tY',
      appId: '1:372121518713:web:6ac45d721bd4cc1d99caa8',
      messagingSenderId: '372121518713',
      projectId: 'qr-menu-a78e9',
      authDomain: 'qr-menu-a78e9.firebaseapp.com',
      storageBucket: 'qr-menu-a78e9.firebasestorage.app',
      measurementId: 'G-0M81DQEY9S',
    );
  }
}

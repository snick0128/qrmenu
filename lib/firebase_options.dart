import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBmYs4vKozkwXJMAzMxVgJ-wqKqzGUx3tY',
    appId: '1:372121518713:web:6ac45d721bd4cc1d99caa8',
    messagingSenderId: '372121518713',
    projectId: 'qr-menu-a78e9',
    authDomain: 'qr-menu-a78e9.firebaseapp.com',
    storageBucket: 'qr-menu-a78e9.firebasestorage.app',
    measurementId: 'G-0M81DQEY9S',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqs_GxKVZh8PXwPuD0itxI6dfQfDP8Q_I',
    appId: '1:372121518713:android:f8793df9c6c8a34499caa8',
    messagingSenderId: '372121518713',
    projectId: 'qr-menu-a78e9',
    storageBucket: 'qr-menu-a78e9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBE77uXZJOuBm63InoBYY5YAhDOd9m1NWE',
    appId: '1:372121518713:ios:17e1cf05826f722299caa8',
    messagingSenderId: '372121518713',
    projectId: 'qr-menu-a78e9',
    storageBucket: 'qr-menu-a78e9.firebasestorage.app',
    iosBundleId: 'com.example.qrmenu',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBE77uXZJOuBm63InoBYY5YAhDOd9m1NWE',
    appId: '1:372121518713:ios:d8e14958c667836799caa8',
    messagingSenderId: '372121518713',
    projectId: 'qr-menu-a78e9',
    storageBucket: 'qr-menu-a78e9.firebasestorage.app',
    iosBundleId: 'com.example.qrmenu.RunnerTests',
  );
}

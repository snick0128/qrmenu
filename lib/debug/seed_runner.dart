import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../utils/firebase_seeder.dart';
import '../services/firebase_service.dart';

/// Debug-only runner to seed Firebase with minimal data.
/// Usage: flutter run -d linux --target=lib/debug/seed_runner.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kDebugMode) {
    // Safety: don't run in release builds
    print('seed_runner: kDebugMode is false — aborting.');
    return;
  }

  try {
    print('seed_runner: Initializing Firebase...');
    await FirebaseService.initialize();
  } catch (e, st) {
    print('seed_runner: Firebase initialization failed: $e');
    print(st);
    // Continue — seeder will likely fail if Firebase isn't initialized.
  }

  try {
    print('seed_runner: Running FirebaseSeeder.seedIfAbsent()...');
    await FirebaseSeeder.seedIfAbsent();
    print('seed_runner: Seeding complete.');
  } catch (e, st) {
    print('seed_runner: Seeding failed: $e');
    print(st);
  }
}

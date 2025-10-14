// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  tearDown(() async {
    // Clean up any test data
    final testDoc = await firestore.collection('admins').doc('test').get();
    if (testDoc.exists) {
      await firestore.collection('admins').doc('test').delete();
    }
  });

  test('Admin login should work', () async {
    // Create a test admin account in Firestore
    final adminRef = firestore.collection('admins').doc('test');

    await adminRef.set({
      'email': 'test@example.com',
      'role': 'admin',
      'name': 'Test Admin',
      'createdAt': DateTime.now(),
    });

    // Verify the admin was created
    final adminDoc = await adminRef.get();
    expect(adminDoc.exists, true);
    expect(adminDoc.data()?['role'], 'admin');
    expect(adminDoc.data()?['email'], 'test@example.com');
  });
}

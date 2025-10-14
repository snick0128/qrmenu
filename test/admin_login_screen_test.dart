import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/screens/admin_login_screen.dart';

void main() {
  group('Admin Login Screen Tests', () {
    late Widget app;

    setUp(() {
      app = const MaterialApp(home: AdminLoginScreen());
    });

    testWidgets('Renders admin login form', (tester) async {
      await tester.pumpWidget(app);

      // Find the key widgets
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('Shows validation errors', (tester) async {
      await tester.pumpWidget(app);

      // Find and tap the submit button
      final submitButton = find.text('Sign In');
      await tester.tap(submitButton);
      await tester.pump();

      // Check validation messages
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Shows validation error for invalid email', (tester) async {
      await tester.pumpWidget(app);

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');

      // Enter valid password
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Submit form
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Check validation message
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('Shows validation error for short password', (tester) async {
      await tester.pumpWidget(app);

      // Enter valid email
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );

      // Enter short password
      await tester.enterText(find.byType(TextFormField).last, '12345');

      // Submit form
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Check validation message
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });
  });
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../services/firebase_service.dart';
import '../services/session_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManualTableEntryScreen extends StatefulWidget {
  final String? restaurantId;
  final String? restaurantName;

  const ManualTableEntryScreen({
    super.key,
    this.restaurantId,
    this.restaurantName,
  });

  @override
  State<ManualTableEntryScreen> createState() => _ManualTableEntryScreenState();
}

class _ManualTableEntryScreenState extends State<ManualTableEntryScreen> {
  final TextEditingController _hotelIdController = TextEditingController();
  final TextEditingController _tableNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.restaurantId != null) {
      _hotelIdController.text = widget.restaurantId!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.restaurantName ?? 'Enter Table Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.restaurantName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.restaurantName!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please enter your table code',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            if (widget.restaurantId == null)
              TextField(
                controller: _hotelIdController,
                decoration: const InputDecoration(
                  labelText: 'Restaurant ID',
                  border: OutlineInputBorder(),
                ),
              ),
            if (widget.restaurantId == null) const SizedBox(height: 20),
            TextField(
              controller: _tableNumberController,
              decoration: const InputDecoration(
                labelText: 'Table Code',
                border: OutlineInputBorder(),
                hintText: 'e.g., TBL_1 or PARCEL_1',
              ),
              textCapitalization:
                  TextCapitalization.characters, // Auto-uppercase
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleProceed,
              child: const Text('Proceed'),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Debug Tools',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _handleSeedData,
                icon: const Icon(Icons.data_array),
                label: const Text('Seed Sample Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleSeedData() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Preparing and seeding data...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      // Clear existing collections
      print('🧹 Clearing existing collections...');

      // Clear restaurants and their subcollections
      final restaurants = await FirebaseService.restaurants.get();
      for (var doc in restaurants.docs) {
        // Clear menus subcollection
        final menuCategories = await FirebaseService.getMenuCollection(
          doc.id,
        ).get();
        for (var category in menuCategories.docs) {
          final items = await category.reference.collection('items').get();
          for (var item in items.docs) {
            await item.reference.delete();
          }
          await category.reference.delete();
        }

        // Clear tables subcollection
        final tables = await FirebaseService.getTablesCollection(doc.id).get();
        for (var table in tables.docs) {
          await table.reference.delete();
        }

        // Clear analytics subcollection
        final analytics = await FirebaseService.getAnalyticsCollection(
          doc.id,
        ).get();
        for (var doc in analytics.docs) {
          await doc.reference.delete();
        }

        // Delete restaurant document
        await doc.reference.delete();
      }

      // Clear access codes collection
      final accessCodes = await FirebaseService.accessCodes.get();
      for (var doc in accessCodes.docs) {
        await doc.reference.delete();
      }

      print('✨ Collections cleared successfully');

      // Create demo restaurant
      await FirebaseService.restaurants.doc('demo_restaurant').set({
        'id': 'demo_restaurant',
        'name': 'Demo Restaurant',
        'address': '123 Demo Street',
        'phone': '+1 (555) 123-4567',
        'cuisine': 'Multi-cuisine',
        'openingTime': '10:00',
        'closingTime': '22:00',
        'isActive': true,
        'rating': 4.5,
      });

      // Set up demo tables
      for (int i = 1; i <= 5; i++) {
        // Create table
        await FirebaseService.getTablesCollection(
          'demo_restaurant',
        ).doc('table_$i').set({
          'name': 'Table $i',
          'number': i,
          'capacity': 4,
          'status': 'vacant',
          'sessionId': null,
          'reservedBy': null,
          'currentTotal': 0.0,
          'reservedAt': null,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Create access code
        final accessCode = 'DEMO_T$i';
        await FirebaseService.accessCodes.doc(accessCode).set({
          'restaurantId': 'demo_restaurant',
          'tableNumber': i.toString(),
          'type': 'dine_in',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Add some menu categories
      final categories = ['Starters', 'Main Course', 'Desserts', 'Beverages'];
      for (var category in categories) {
        await FirebaseService.getMenuCollection(
          'demo_restaurant',
        ).doc(category).set({
          'name': category,
          'displayOrder': categories.indexOf(category),
          'isActive': true,
        });

        // Add sample items
        await FirebaseService.getMenuCollection(
          'demo_restaurant',
        ).doc(category).collection('items').add({
          'name': 'Sample ${category.toLowerCase()}',
          'description': 'A delicious sample item',
          'price': 100.0 + (categories.indexOf(category) * 50),
          'isVeg': true,
          'isSpicy': false,
          'isAvailable': true,
          'rating': 4.5,
          'isPopular': true,
          'preparationTime': '10-15 min',
        });
      }

      // Hide loading and show success
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample data seeded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Pre-fill the demo restaurant ID
      setState(() {
        _hotelIdController.text = 'demo_restaurant';
        _tableNumberController.text = 'TBL_1';
      });
    } catch (e) {
      // Hide loading
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to seed data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleProceed() async {
    final hotelId = _hotelIdController.text.trim();
    final tableNumber = _tableNumberController.text
        .trim()
        .toUpperCase(); // Normalize to uppercase

    if (hotelId.isEmpty || tableNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both hotel ID and table code'),
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Validate restaurant
      final restaurantDoc = await FirebaseService.restaurants
          .doc(hotelId)
          .get();

      // Hide loading indicator
      if (!mounted) return;
      Navigator.of(context).pop();

      if (!restaurantDoc.exists) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Restaurant'),
            content: const Text(
              'The restaurant ID was not found. Please check and try again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Validate table code
      final tableDoc = await FirebaseService.accessCodes.doc(tableNumber).get();
      if (!tableDoc.exists) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Table Code'),
            content: const Text(
              'The table code was not found. Please check and try again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      final tableData = tableDoc.data() as Map<String, dynamic>;
      final isActive = tableData['isActive'] as bool? ?? false;

      if (!isActive) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Inactive Table'),
            content: const Text(
              'This table is currently not active. Please try a different table code.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Create/update guest session
      await SessionService.createOrUpdateGuestSession(
        hotelId: hotelId,
        tableNo: tableNumber,
      );

      // Navigate to menu
      if (!mounted) return;
      context.go('/$hotelId/$tableNumber');
    } catch (e) {
      // Hide loading indicator if visible
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _hotelIdController.dispose();
    _tableNumberController.dispose();
    super.dispose();
  }
}

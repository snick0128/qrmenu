import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_service.dart';

class ManualTableEntryScreen extends StatefulWidget {
  final String? restaurantId;
  final String? restaurantName;

  const ManualTableEntryScreen({super.key, this.restaurantId, this.restaurantName});

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
      appBar: AppBar(
        title: Text(widget.restaurantName ?? 'Enter Table Code'),
      ),
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
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
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
              textCapitalization: TextCapitalization.characters, // Auto-uppercase
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
  final hotelId = _hotelIdController.text.trim();
  final tableNumber = _tableNumberController.text.trim().toUpperCase(); // Normalize to uppercase
  
  if (hotelId.isNotEmpty && tableNumber.isNotEmpty) {
    final restaurantDoc = await FirebaseService.restaurants.doc(hotelId).get();
    if (!restaurantDoc.exists) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Invalid Hotel ID'),
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

    final tableDoc = await FirebaseService.accessCodes.doc(tableNumber).get();
    if (!tableDoc.exists) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Invalid Table Number'),
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

    context.go('/$hotelId/$tableNumber');
  }
},
              child: const Text('Proceed'),
            ),
          ],
        ),
      ),
    );
  }
}
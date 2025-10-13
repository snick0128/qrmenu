import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'screens/manual_table_entry_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/error_screen.dart';
import 'providers/dining_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/app_language_provider.dart';
import 'providers/order_history_provider.dart';
import 'utils/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase Core initialized successfully');

    await FirebaseService.initialize();
    debugPrint('FirebaseService initialized successfully');

    final user = await AuthService.signInAsGuest();
    if (user != null) {
      debugPrint('Using guest user: ${user.uid}');
    }
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  runApp(const QRMenuApp());
}

class QRMenuApp extends StatelessWidget {
  const QRMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      debugLogDiagnostics: true, // Enable router debug logs
      routes: [
        GoRoute(
          path: '/:restaurantId/:tableCode',
          builder: (context, state) {
            final restaurantId = state.pathParameters['restaurantId']!;
            final tableCode = state.pathParameters['tableCode']!; // Keep original case from URL
            
            debugPrint('🔍 URL Params - Restaurant: $restaurantId, Table Code: $tableCode');

            return FutureBuilder<DocumentSnapshot?>(
              future: FirebaseService.restaurants.doc(restaurantId).get(),
              builder: (context, restaurantSnapshot) {
                if (restaurantSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Invalid restaurant ID - show error page
                if (!restaurantSnapshot.hasData || !restaurantSnapshot.data!.exists) {
                  debugPrint('❌ Restaurant NOT found: $restaurantId');
                  return const ErrorScreen(
                    message: 'Invalid Restaurant ID. Please check your QR code and try again.',
                  );
                }

                final restaurantData = restaurantSnapshot.data!.data() as Map<String, dynamic>;
                final restaurantName = restaurantData['name'] as String;
                debugPrint('✅ Restaurant found: $restaurantName');

                // Now validate the table code
                return FutureBuilder<DocumentSnapshot?>(
                  future: FirebaseService.accessCodes.doc(tableCode).get(),
                  builder: (context, tableSnapshot) {
                    if (tableSnapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    // Invalid table code - go to manual entry with restaurant info
                    if (!tableSnapshot.hasData || !tableSnapshot.data!.exists) {
                      debugPrint('❌ Table code NOT found: $tableCode');
                      return ManualTableEntryScreen(
                        restaurantId: restaurantId,
                        restaurantName: restaurantName,
                      );
                    }

                    final tableData = tableSnapshot.data!.data() as Map<String, dynamic>;
                    final isActive = tableData['isActive'] as bool? ?? false;
                    final sessionType = tableData['type'] as String? ?? 'unknown';
                    
                    debugPrint('📋 Table data - isActive: $isActive, type: $sessionType');
                    debugPrint('📄 Full table data: $tableData');
                    
                    // Inactive table code - go to manual entry
                    if (!isActive) {
                      debugPrint('⚠️ Table code is INACTIVE: $tableCode');
                      return ManualTableEntryScreen(
                        restaurantId: restaurantId,
                        restaurantName: restaurantName,
                      );
                    }

                    debugPrint('✅ Valid table code! Navigating to menu...');
                    
                    // Valid restaurant and table code - proceed to menu
                    return MenuScreen(
                      restaurantName: restaurantName,
                      tableNumber: tableCode,
                      sessionType: sessionType,
                    );
                  },
                );
              },
            );
          },
        ),
        GoRoute(
          path: '/:restaurantId',
          builder: (context, state) {
            final restaurantId = state.pathParameters['restaurantId']!;
            
            // Validate restaurant before showing manual entry
            return FutureBuilder<DocumentSnapshot?>(
              future: FirebaseService.restaurants.doc(restaurantId).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const ErrorScreen(
                    message: 'Invalid Restaurant ID. Please check your QR code and try again.',
                  );
                }

                final restaurantData = snapshot.data!.data() as Map<String, dynamic>;
                final restaurantName = restaurantData['name'] as String;

                return ManualTableEntryScreen(
                  restaurantId: restaurantId,
                  restaurantName: restaurantName,
                );
              },
            );
          },
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const ManualTableEntryScreen(),
        ),
      ],
      errorBuilder: (context, state) => const ManualTableEntryScreen(),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
        ChangeNotifierProvider(create: (_) => DiningProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => OrderHistoryProvider()),
      ],
      child: Consumer<AppLanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp.router(
            title: 'QR Menu',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            routerConfig: router,
          );
        },
      ),
    );
  }
}

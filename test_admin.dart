import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qrmenu/core/firebase/firebase_service.dart';
import 'package:qrmenu/core/models/date_filter_type.dart';
import 'package:qrmenu/core/services/admin_service.dart';
import 'lib/firebase_options.dart';

/// Simple test script to verify admin functionality
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔥 Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('📊 Initializing Admin Services...');
  await FirebaseService.initialize();
  await AdminService.initializeTables();
  
  print('✅ Testing Sales Analytics...');
  try {
    final analytics = await AdminService.getSalesAnalytics(DateFilterType.today);
    print('📈 Today Analytics: ${analytics.toJson()}');
  } catch (e) {
    print('❌ Analytics Error: $e');
  }
  
  print('🍽️ Testing Tables Stream...');
  try {
    AdminService.getTablesStream().take(1).listen((tables) {
      print('📋 Found ${tables.length} tables');
      for (final table in tables.take(3)) {
        print('   • ${table.name}: ${table.statusText}');
      }
    });
  } catch (e) {
    print('❌ Tables Error: $e');
  }
  
  print('📦 Testing Orders Stream...');
  try {
    AdminService.getOrdersStream().take(1).listen((orders) {
      print('🛍️ Found ${orders.length} orders');
    });
  } catch (e) {
    print('❌ Orders Error: $e');
  }
  
  // Wait a bit for streams to respond
  await Future.delayed(const Duration(seconds: 3));
  
  print('🎉 Admin System Test Complete!');
}
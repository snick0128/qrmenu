import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

enum PaymentMethod { online, counter }

enum PaymentStatus { pending, processing, completed, failed, cancelled }

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  // Process online payment
  Future<Map<String, dynamic>> processOnlinePayment({
    required String orderId,
    required double amount,
    String currency = 'INR',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // In a real implementation, this would integrate with a payment gateway
      // For now, we'll simulate a successful payment
      await Future.delayed(const Duration(seconds: 2));

      final paymentData = {
        'orderId': orderId,
        'amount': amount,
        'currency': currency,
        'status': PaymentStatus.completed.toString(),
        'method': PaymentMethod.online.toString(),
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': metadata ?? {},
      };

      // Save payment record to Firestore
      await FirebaseService.firestore
          .collection('payments')
          .doc(orderId)
          .set(paymentData);

      return {
        'success': true,
        'message': 'Payment processed successfully',
        'data': paymentData,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Payment failed: $e',
        'error': e.toString(),
      };
    }
  }

  // Mark payment as completed at counter
  Future<Map<String, dynamic>> markCounterPayment({
    required String orderId,
    required double amount,
    String? note,
  }) async {
    try {
      final paymentData = {
        'orderId': orderId,
        'amount': amount,
        'currency': 'INR',
        'status': PaymentStatus.completed.toString(),
        'method': PaymentMethod.counter.toString(),
        'timestamp': FieldValue.serverTimestamp(),
        'note': note,
      };

      // Save payment record
      await FirebaseService.firestore
          .collection('payments')
          .doc(orderId)
          .set(paymentData);

      // Update order status
      await FirebaseService.updateOrderStatus(orderId, 'completed');

      return {
        'success': true,
        'message': 'Counter payment recorded successfully',
        'data': paymentData,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to record payment: $e',
        'error': e.toString(),
      };
    }
  }

  // Get payment status
  Future<Map<String, dynamic>> getPaymentStatus(String orderId) async {
    try {
      final doc = await FirebaseService.firestore
          .collection('payments')
          .doc(orderId)
          .get();

      if (!doc.exists) {
        return {
          'success': false,
          'message': 'Payment record not found',
          'status': PaymentStatus.pending.toString(),
        };
      }

      return {
        'success': true,
        'data': doc.data(),
        'status': doc.data()?['status'] ?? PaymentStatus.pending.toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get payment status: $e',
        'status': PaymentStatus.failed.toString(),
      };
    }
  }

  // Cancel payment
  Future<Map<String, dynamic>> cancelPayment(String orderId) async {
    try {
      await FirebaseService.firestore
          .collection('payments')
          .doc(orderId)
          .update({
            'status': PaymentStatus.cancelled.toString(),
            'cancelledAt': FieldValue.serverTimestamp(),
          });

      // Update order status
      await FirebaseService.updateOrderStatus(orderId, 'cancelled');

      return {'success': true, 'message': 'Payment cancelled successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to cancel payment: $e',
        'error': e.toString(),
      };
    }
  }
}

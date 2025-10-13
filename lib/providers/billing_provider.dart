import 'package:flutter/foundation.dart';
import '../services/admin_service.dart';

class BillingProvider extends ChangeNotifier {
  Map<String, dynamic>? _currentBill;
  bool _isGenerating = false;
  bool _isProcessingPayment = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get currentBill => _currentBill;
  bool get isGenerating => _isGenerating;
  bool get isProcessingPayment => _isProcessingPayment;
  String? get error => _error;

  // Generate bill for session
  Future<void> generateBill(String sessionId, String sessionType) async {
    try {
      _isGenerating = true;
      _error = null;
      notifyListeners();

      _currentBill = await AdminService.generateBill(sessionId, sessionType);
      _isGenerating = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isGenerating = false;
      notifyListeners();
      rethrow;
    }
  }

  // Process payment
  Future<void> processPayment(
    String sessionId,
    String sessionType,
    String paymentMethod,
  ) async {
    try {
      _isProcessingPayment = true;
      _error = null;
      notifyListeners();

      await AdminService.completePayment(sessionId, sessionType, paymentMethod);
      
      _isProcessingPayment = false;
      _currentBill = null; // Clear bill after successful payment
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isProcessingPayment = false;
      notifyListeners();
      rethrow;
    }
  }

  // Clear current bill
  void clearBill() {
    _currentBill = null;
    _error = null;
    notifyListeners();
  }

  // Reset provider
  void reset() {
    _currentBill = null;
    _isGenerating = false;
    _isProcessingPayment = false;
    _error = null;
    notifyListeners();
  }
}
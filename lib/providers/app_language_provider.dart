import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguageProvider extends ChangeNotifier {
  String _languageCode = 'en';
  static const String _languageKey = 'selected_language';

  String get languageCode => _languageCode;

  String get languageName {
    switch (_languageCode) {
      case 'hi':
        return 'Hindi';
      case 'mr':
        return 'Marathi';
      default:
        return 'English';
    }
  }

  // Initialize language from saved preferences
  Future<void> initializeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    
    if (savedLanguage != null && ['en', 'hi', 'mr'].contains(savedLanguage)) {
      _languageCode = savedLanguage;
      notifyListeners();
    }
  }

  // Set language and save to preferences
  Future<void> setLanguage(String languageCode) async {
    if (languageCode == _languageCode) return;
    
    _languageCode = languageCode;
    
    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    
    notifyListeners();
  }

  // Get localized text - Simple implementation
  String getText(String key) {
    final translations = _getTranslations(_languageCode);
    return translations[key] ?? key;
  }

  Map<String, String> _getTranslations(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return _hindiTranslations;
      case 'mr':
        return _marathiTranslations;
      default:
        return _englishTranslations;
    }
  }

  // English translations (default)
  static const Map<String, String> _englishTranslations = {
    // App Common
    'app_name': 'QR Menu',
    'welcome': 'Welcome',
    'continue': 'Continue',
    'cancel': 'Cancel',
    'ok': 'OK',
    'yes': 'Yes',
    'no': 'No',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'back': 'Back',
    'next': 'Next',
    'skip': 'Skip',
    'loading': 'Loading...',
    
    // Language Selection
    'select_language': 'Please select your preferred language',
    'skip_for_now': 'Skip for now',
    
    // QR Scanner
    'scan_qr': 'Scan QR Code',
    'point_camera': 'Point your camera at the QR code',
    'qr_instructions': 'The QR code should be clearly visible within the frame',
    'demo_menu': 'Demo Menu (For Testing)',
    'camera_permission_required': 'Camera Permission Required',
    'grant_camera_permission': 'Please grant camera permission to scan QR codes',
    'processing_qr': 'Processing QR code...',
    
    // Menu Screen
    'menu': 'Menu',
    'search_menu': 'Search menu items...',
    'all': 'All',
    'vegetarian': 'Vegetarian',
    'non_vegetarian': 'Non-Vegetarian',
    'veg': 'Veg',
    'non_veg': 'Non-Veg',
    'no_items_found': 'No items found',
    'adjust_search_filter': 'Try adjusting your search or category filter',
    'quick_order': 'Quick Order',
    'show_quick_order': 'Show Quick Order',
    'hide_quick_order': 'Hide Quick Order',
    'spicy': 'Spicy',
    'contains': 'Contains:',
    'preparation_time': 'Prep time:',
    'special_instructions': 'Special Instructions (Optional)',
    'special_instructions_hint': 'e.g., Extra spicy, less oil, etc.',
    'quantity': 'Quantity:',
    'add_to_cart': 'Add to Cart',
    'added_to_cart': 'added to cart',
    'view_cart': 'VIEW CART',
    
    // Cart Screen
    'your_order': 'Your Order',
    'clear_all': 'Clear All',
    'cart_empty': 'Your cart is empty',
    'cart_empty_subtitle': 'Add some delicious items from the menu',
    'browse_menu': 'Browse Menu',
    'clear_cart': 'Clear Cart',
    'clear_cart_confirm': 'Are you sure you want to remove all items from your cart?',
    'cart_cleared': 'Cart cleared',
    'removed_from_cart': 'removed from cart',
    'subtotal': 'Subtotal',
    'tax_gst': 'Tax (GST)',
    'service_charge': 'Service Charge',
    'total': 'Total',
    'place_order': 'Place Order',
    
    // Order Types
    'order_type': 'Order Type',
    'select_order_type': 'How would you like to receive your order?',
    'dine_in': 'Dine In',
    'dine_in_desc': 'Eat at the restaurant',
    'takeaway': 'Takeaway',
    'takeaway_desc': 'Pick up your order',
    'delivery': 'Delivery',
    'delivery_desc': 'Get it delivered to your address',
    'table_number': 'Table',
    'delivery_address': 'Delivery Address',
    'enter_delivery_address': 'Enter your delivery address',
    'address_required': 'Please enter a delivery address',
    
    // Checkout
    'checkout': 'Checkout',
    'order_summary': 'Order Summary',
    'payment_method': 'Payment Method',
    'select_payment': 'Select Payment Method',
    'upi_payment': 'UPI Payment',
    'cash_payment': 'Cash Payment',
    'pay_with_upi': 'Pay with UPI',
    'pay_with_cash': 'Pay with Cash',
    'confirm_order': 'Confirm Order',
    'order_confirmation': 'Order Confirmation',
    'review_order': 'Review Order',
    'estimated_time': 'Estimated preparation time: 20-30 minutes',
    
    // Order Tracking
    'order_tracking': 'Order Tracking',
    'order_placed': 'Order Placed!',
    'order_id': 'Order ID',
    'order_status': 'Order Status',
    'pending': 'Pending',
    'preparing': 'Preparing',
    'ready': 'Ready',
    'served': 'Served',
    'delivered': 'Delivered',
    'track_your_order': 'Track Your Order',
    'order_received': 'Order received by kitchen',
    'being_prepared': 'Your order is being prepared',
    'order_ready': 'Order is ready for pickup/serving',
    'order_completed': 'Order completed',
    'continue_browsing': 'Continue Browsing',
    
    // Feedback
    'feedback': 'Feedback',
    'rate_order': 'Rate Your Order',
    'rate_experience': 'How was your dining experience?',
    'leave_comment': 'Leave a comment (optional)',
    'comment_hint': 'Tell us about your experience...',
    'submit_feedback': 'Submit Feedback',
    'thank_you_feedback': 'Thank you for your feedback!',
    'rating_required': 'Please select a rating',
    
    // Order History
    'order_history': 'Order History',
    'past_orders': 'Your Past Orders',
    'no_past_orders': 'No past orders found',
    'no_past_orders_subtitle': 'Your order history will appear here',
    'reorder': 'Reorder',
    'order_date': 'Order Date',
    'order_total': 'Total',
    'items_count': 'items',
    'view_details': 'View Details',
    'reorder_confirmation': 'Add these items to your cart?',
    'items_added_to_cart': 'Items added to cart',
  };

  // Hindi translations
  static const Map<String, String> _hindiTranslations = {
    // App Common
    'app_name': 'QR मेन्यू',
    'welcome': 'स्वागत है',
    'continue': 'जारी रखें',
    'cancel': 'रद्द करें',
    'ok': 'ठीक है',
    'yes': 'हाँ',
    'no': 'नहीं',
    'save': 'सेव करें',
    'delete': 'डिलीट करें',
    'edit': 'संपादित करें',
    'back': 'वापस',
    'next': 'अगला',
    'skip': 'छोड़ें',
    'loading': 'लोड हो रहा है...',
    
    // Language Selection
    'select_language': 'कृपया अपनी पसंदीदा भाषा चुनें',
    'skip_for_now': 'अभी के लिए छोड़ें',
    
    // QR Scanner
    'scan_qr': 'QR कोड स्कैन करें',
    'point_camera': 'अपना कैमरा QR कोड पर लगाएं',
    'qr_instructions': 'QR कोड फ्रेम के अंदर स्पष्ट रूप से दिखना चाहिए',
    'demo_menu': 'डेमो मेन्यू (परीक्षण के लिए)',
    'camera_permission_required': 'कैमरा अनुमति आवश्यक',
    'grant_camera_permission': 'QR कोड स्कैन करने के लिए कैमरा अनुमति दें',
    'processing_qr': 'QR कोड प्रोसेस हो रहा है...',
    
    // Menu Screen
    'menu': 'मेन्यू',
    'search_menu': 'मेन्यू आइटम खोजें...',
    'all': 'सभी',
    'vegetarian': 'शाकाहारी',
    'non_vegetarian': 'मांसाहारी',
    'veg': 'वेज',
    'non_veg': 'नॉन-वेज',
    'no_items_found': 'कोई आइटम नहीं मिला',
    'adjust_search_filter': 'अपना खोज या श्रेणी फिल्टर समायोजित करने का प्रयास करें',
    'quick_order': 'क्विक ऑर्डर',
    'show_quick_order': 'क्विक ऑर्डर दिखाएं',
    'hide_quick_order': 'क्विक ऑर्डर छुपाएं',
    'spicy': 'तीखा',
    'contains': 'शामिल है:',
    'preparation_time': 'तैयारी का समय:',
    'special_instructions': 'विशेष निर्देश (वैकल्पिक)',
    'special_instructions_hint': 'जैसे: अतिरिक्त तीखा, कम तेल, आदि',
    'quantity': 'मात्रा:',
    'add_to_cart': 'कार्ट में डालें',
    'added_to_cart': 'कार्ट में जोड़ा गया',
    'view_cart': 'कार्ट देखें',
    
    // Cart Screen
    'your_order': 'आपका ऑर्डर',
    'clear_all': 'सभी साफ करें',
    'cart_empty': 'आपका कार्ट खाली है',
    'cart_empty_subtitle': 'मेन्यू से कुछ स्वादिष्ट आइटम जोड़ें',
    'browse_menu': 'मेन्यू ब्राउज़ करें',
    'clear_cart': 'कार्ट साफ करें',
    'clear_cart_confirm': 'क्या आप वाकई अपने कार्ट से सभी आइटम हटाना चाहते हैं?',
    'cart_cleared': 'कार्ट साफ कर दिया गया',
    'removed_from_cart': 'कार्ट से हटा दिया गया',
    'subtotal': 'उप योग',
    'tax_gst': 'टैक्स (GST)',
    'service_charge': 'सेवा शुल्क',
    'total': 'कुल योग',
    'place_order': 'ऑर्डर करें',
    
    // Order Types
    'order_type': 'ऑर्डर का प्रकार',
    'select_order_type': 'आप अपना ऑर्डर कैसे प्राप्त करना चाहेंगे?',
    'dine_in': 'डाइन इन',
    'dine_in_desc': 'रेस्टोरेंट में खाएं',
    'takeaway': 'टेकअवे',
    'takeaway_desc': 'अपना ऑर्डर लेकर जाएं',
    'delivery': 'डिलीवरी',
    'delivery_desc': 'अपने पते पर मंगवाएं',
    'table_number': 'टेबल',
    'delivery_address': 'डिलीवरी पता',
    'enter_delivery_address': 'अपना डिलीवरी पता दर्ज करें',
    'address_required': 'कृपया डिलीवरी पता दर्ज करें',
    
    // Checkout
    'checkout': 'चेकआउट',
    'order_summary': 'ऑर्डर सारांश',
    'payment_method': 'भुगतान विधि',
    'select_payment': 'भुगतान विधि चुनें',
    'upi_payment': 'UPI भुगतान',
    'cash_payment': 'कैश भुगतान',
    'pay_with_upi': 'UPI से भुगतान करें',
    'pay_with_cash': 'कैश में भुगतान करें',
    'confirm_order': 'ऑर्डर पुष्टि करें',
    'order_confirmation': 'ऑर्डर पुष्टि',
    'review_order': 'ऑर्डर की समीक्षा करें',
    'estimated_time': 'अनुमानित तैयारी समय: 20-30 मिनट',
  };

  // Marathi translations
  static const Map<String, String> _marathiTranslations = {
    // App Common
    'app_name': 'QR मेनू',
    'welcome': 'स्वागत',
    'continue': 'सुरू ठेवा',
    'cancel': 'रद्द करा',
    'ok': 'ठीक आहे',
    'yes': 'होय',
    'no': 'नाही',
    'save': 'जतन करा',
    'delete': 'हटवा',
    'edit': 'संपादन करा',
    'back': 'परत',
    'next': 'पुढे',
    'skip': 'वगळा',
    'loading': 'लोड होत आहे...',
    
    // Language Selection
    'select_language': 'कृपया तुमची आवडती भाषा निवडा',
    'skip_for_now': 'सध्या वगळा',
    
    // QR Scanner
    'scan_qr': 'QR कोड स्कॅन करा',
    'point_camera': 'तुमचा कॅमेरा QR कोडवर लावा',
    'qr_instructions': 'QR कोड फ्रेममध्ये स्पष्टपणे दिसला पाहिजे',
    'demo_menu': 'डेमो मेनू (चाचणीसाठी)',
    'camera_permission_required': 'कॅमेरा परवानगी आवश्यक',
    'grant_camera_permission': 'QR कोड स्कॅन करण्यासाठी कॅमेरा परवानगी द्या',
    'processing_qr': 'QR कोड प्रक्रिया करत आहे...',
    
    // Menu Screen
    'menu': 'मेनू',
    'search_menu': 'मेनू आयटम शोधा...',
    'all': 'सर्व',
    'vegetarian': 'शाकाहारी',
    'non_vegetarian': 'मांसाहारी',
    'veg': 'वेज',
    'non_veg': 'नॉन-वेज',
    'no_items_found': 'कोणते आयटम सापडले नाहीत',
    'adjust_search_filter': 'तुमचा शोध किंवा श्रेणी फिल्टर समायोजित करण्याचा प्रयत्न करा',
    'quick_order': 'क्विक ऑर्डर',
    'show_quick_order': 'क्विक ऑर्डर दाखवा',
    'hide_quick_order': 'क्विक ऑर्डर लपवा',
    'spicy': 'तिखट',
    'contains': 'समाविष्ट आहे:',
    'preparation_time': 'तयारीचा वेळ:',
    'special_instructions': 'विशेष सूचना (वैकल्पिक)',
    'special_instructions_hint': 'जसे: अतिरिक्त तिखट, कमी तेल, इ.',
    'quantity': 'प्रमाण:',
    'add_to_cart': 'कार्टमध्ये टाका',
    'added_to_cart': 'कार्टमध्ये जोडले',
    'view_cart': 'कार्ट पहा',
    
    // Cart Screen
    'your_order': 'तुमचा ऑर्डर',
    'clear_all': 'सर्व साफ करा',
    'cart_empty': 'तुमची कार्ट रिकामी आहे',
    'cart_empty_subtitle': 'मेनूमधून काही स्वादिष्ट आयटम जोडा',
    'browse_menu': 'मेनू ब्राउझ करा',
    'clear_cart': 'कार्ट साफ करा',
    'clear_cart_confirm': 'तुम्हाला खरोखर तुमच्या कार्टमधील सर्व आयटम काढायचे आहेत का?',
    'cart_cleared': 'कार्ट साफ केली',
    'removed_from_cart': 'कार्टमधून काढले',
    'subtotal': 'उप एकूण',
    'tax_gst': 'कर (GST)',
    'service_charge': 'सेवा शुल्क',
    'total': 'एकूण',
    'place_order': 'ऑर्डर द्या',
    
    // Order Types
    'order_type': 'ऑर्डर प्रकार',
    'select_order_type': 'तुम्हाला तुमचा ऑर्डर कसा मिळवायचा आहे?',
    'dine_in': 'डाइन इन',
    'dine_in_desc': 'रेस्टॉरंटमध्ये जेवा',
    'takeaway': 'टेकअवे',
    'takeaway_desc': 'तुमचा ऑर्डर घेऊन जा',
    'delivery': 'डिलिव्हरी',
    'delivery_desc': 'तुमच्या पत्त्यावर मागवा',
    'table_number': 'टेबल',
    'delivery_address': 'डिलिव्हरी पत्ता',
    'enter_delivery_address': 'तुमचा डिलिव्हरी पत्ता टाका',
    'address_required': 'कृपया डिलिव्हरी पत्ता टाका',
  };
}

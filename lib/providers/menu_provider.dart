import 'package:flutter/foundation.dart';
import '../models/menu_item_model.dart';
import '../models/restaurant_model.dart';
import '../models/category_model.dart';
import '../services/firebase_service.dart';

class MenuProvider with ChangeNotifier {
  RestaurantModel? _restaurant;
  List<MenuItemModel> _menuItems = [];
  String _selectedCategory = '';
  String _searchQuery = '';
  bool _isLoading = false;

  // Getters
  RestaurantModel? get restaurant => _restaurant;
  List<MenuItemModel> get menuItems => _filteredItems;
  String get selectedCategory => _selectedCategory;
  CategoryModel? get selectedCategoryModel => _selectedCategory.isNotEmpty ? CategoryModel.fromString(_selectedCategory) : null;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<String> get categories => _getCategories();
  List<CategoryModel> get categoryModels => _getCategoryModels();
  List<MenuItemModel> get quickOrderItems => _getQuickOrderItems();
  List<MenuItemModel> get popularItems => _getPopularItems();
  List<MenuItemModel> get filteredMenuItems => _filteredItems;

  // Private getter for filtered items
  List<MenuItemModel> get _filteredItems {
    List<MenuItemModel> filtered = List.from(_menuItems);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = _searchItems(_searchQuery);
    }

    // Apply category filter
    if (_selectedCategory.isNotEmpty) {
      filtered = filtered
          .where((item) => item.category == _selectedCategory)
          .toList();
    }

    return filtered;
  }

  // Initialize with Firebase data
  Future<void> initializeWithFirebaseData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load menu items from Firebase
      final menuItemsSnapshot = await FirebaseService.menuItems.get();
      final menuItemsData = menuItemsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MenuItemModel(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          category: data['category'] ?? 'Other',
          imageUrl: data['imageUrl'] ?? '',
          isAvailable: data['isAvailable'] ?? true,
          isVeg: data['isVegetarian'] ?? false,
          isSpicy:
              data['spicyLevel'] != null && (data['spicyLevel'] as int) > 0,
          isPopular: data['isPopular'] ?? false,
          isQuickOrder: data['isQuickOrder'] ?? false,
          preparationTime: data['preparationTime']?.toString() ?? '15-20 min',
        );
      }).toList();

      _menuItems = menuItemsData;

      // Create a default restaurant model
      _restaurant = RestaurantModel(
        id: 'default_restaurant',
        name: 'Our Restaurant',
        address: '123 Main Street, City',
        phone: '+1 (555) 123-4567',
        logoUrl: '',
      );

      print('Loaded ${_menuItems.length} menu items from Firebase');
    } catch (e) {
      print('Error loading menu data from Firebase: $e');
      // Fallback to empty data
      _menuItems = [];
      _restaurant = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize with mock data (now calls Firebase)
  void initializeWithMockData() {
    initializeWithFirebaseData();
  }

  // Set data from an external seed (local JSON or Firestore snapshot)
  void setDataFromSeed(RestaurantModel restaurant, List<MenuItemModel> items) {
    _isLoading = true;
    notifyListeners();

    _restaurant = restaurant;
    _menuItems = List.from(items);

    _isLoading = false;
    notifyListeners();
  }

  // Set restaurant from QR scan
  void setRestaurantFromQR(RestaurantModel restaurant) {
    _restaurant = restaurant;
    notifyListeners();
  }

  // Backwards-compatible setter used in other screens
  void setRestaurant(RestaurantModel restaurant) =>
      setRestaurantFromQR(restaurant);

  // Category management
  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearCategoryFilter() {
    _selectedCategory = '';
    notifyListeners();
  }

  // Search functionality
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Helper methods
  List<String> _getCategories() {
    final categories = _menuItems.map((item) => item.category).toSet().toList();
    categories.sort();
    return categories;
  }

  List<CategoryModel> _getCategoryModels() {
    return _getCategories().map((cat) => CategoryModel.fromString(cat)).toList();
  }

  List<MenuItemModel> _getQuickOrderItems() {
    return _menuItems.where((item) => item.isQuickOrder).toList();
  }

  List<MenuItemModel> _getPopularItems() {
    return _menuItems.where((item) => item.isPopular).toList();
  }

  List<MenuItemModel> _searchItems(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _menuItems.where((item) {
      return item.name.toLowerCase().contains(lowercaseQuery) ||
          item.description.toLowerCase().contains(lowercaseQuery) ||
          item.category.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Public search method
  List<MenuItemModel> searchItems(String query) {
    return _searchItems(query);
  }

  // Get items by category
  List<MenuItemModel> getItemsByCategory(String category) {
    return _menuItems.where((item) => item.category == category).toList();
  }

  // Get available items only
  List<MenuItemModel> get availableItems {
    return _menuItems.where((item) => item.isAvailable).toList();
  }

  // Get vegetarian items only
  List<MenuItemModel> get vegetarianItems {
    return _menuItems.where((item) => item.isVeg).toList();
  }

  // Get spicy items only
  List<MenuItemModel> get spicyItems {
    return _menuItems.where((item) => item.isSpicy).toList();
  }

  // Clear all data
  void clearData() {
    _restaurant = null;
    _menuItems = [];
    _selectedCategory = '';
    _searchQuery = '';
    notifyListeners();
  }
}

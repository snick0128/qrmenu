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
  CategoryModel? get selectedCategoryModel => _selectedCategory.isNotEmpty
      ? CategoryModel.fromString(_selectedCategory)
      : null;
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
  Future<void> initializeWithFirebaseData(String hotelId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load restaurant data
      final restaurantDoc = await FirebaseService.restaurants
          .doc(hotelId)
          .get();
      if (!restaurantDoc.exists) {
        throw Exception('Restaurant not found');
      }

      final restaurantData = restaurantDoc.data() as Map<String, dynamic>;
      _restaurant = RestaurantModel(
        id: hotelId,
        name: restaurantData['name'] ?? 'Unknown Restaurant',
        address: restaurantData['address'] ?? '',
        phone: restaurantData['phone'] ?? '',
        logoUrl: restaurantData['logoUrl'] ?? '',
      );

      // Load menu items from Firebase
      final menuCollection = FirebaseService.getMenuCollection(hotelId);
      final menuItemsSnapshot = await menuCollection.get();

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

      // Load analytics for popular items
      final analyticsRef = FirebaseService.getAnalyticsCollection(hotelId);
      final analyticsSnapshot = await analyticsRef.doc('mostOrdered').get();

      if (analyticsSnapshot.exists) {
        final data = analyticsSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('items')) {
          final popularItemsMap = data['items'] as Map<String, dynamic>;
          // Sort by order count descending
          final sortedItems = popularItemsMap.entries.toList()
            ..sort((a, b) => (b.value as int).compareTo(a.value as int));

          // Take top 10 popular item IDs
          final popularItemIds = sortedItems.take(10).map((e) => e.key).toSet();

          // Create new menu items list with updated popularity
          _menuItems = _menuItems
              .map(
                (item) => MenuItemModel(
                  id: item.id,
                  name: item.name,
                  description: item.description,
                  price: item.price,
                  category: item.category,
                  imageUrl: item.imageUrl,
                  isAvailable: item.isAvailable,
                  isVeg: item.isVeg,
                  isSpicy: item.isSpicy,
                  isPopular: popularItemIds.contains(item.id),
                  isQuickOrder: item.isQuickOrder,
                  preparationTime: item.preparationTime,
                ),
              )
              .toList();
        }
      }

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

  // Initialize with mock data (now calls Firebase with default restaurant)
  Future<void> initializeWithMockData() async {
    await initializeWithFirebaseData('default_restaurant');
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

  // Set restaurant and load its data from QR scan
  Future<void> setRestaurantFromQR(RestaurantModel restaurant) async {
    _restaurant = restaurant;
    notifyListeners();
    await initializeWithFirebaseData(restaurant.id);
  }

  // Backwards-compatible setter used in other screens
  Future<void> setRestaurant(RestaurantModel restaurant) async {
    await setRestaurantFromQR(restaurant);
  }

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
    return _getCategories()
        .map((cat) => CategoryModel.fromString(cat))
        .toList();
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

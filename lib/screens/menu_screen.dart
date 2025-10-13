import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../models/menu_item_model.dart';
import '../widgets/quick_order_bar.dart';
import '../widgets/category_tabs.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/web_menu_grid.dart';
import '../widgets/menu_section_widget.dart';
import '../utils/app_theme.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';
import 'search_results_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
    this.initialTabIndex = 0,
    this.tableNumber,
    this.sessionType,
    this.restaurantName,
  });

  final int initialTabIndex;
  final String? tableNumber;
  final String? sessionType;
  final String? restaurantName;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String? _sessionId;
  String? _sessionType;
  String? _tableNumber;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    // Initialize menu data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().initializeWithFirebaseData();
      final cartProvider = context.read<CartProvider>();
      
      // Use widget parameters or fallback to provider values
      final tableNum = widget.tableNumber ?? cartProvider.tableNumber ?? '';
      final sessType = widget.sessionType ?? cartProvider.sessionType ?? 'dine_in';
      
      if (widget.tableNumber != null && widget.sessionType != null) {
        cartProvider.initializeSession(
          tableNum,
          sessType,
          tableNumber: tableNum,
        );
        cartProvider.loadFromFirebase(tableNum, sessType);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MenuProvider, CartProvider>(
      builder: (context, menuProvider, cartProvider, child) {
        if (menuProvider.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading menu...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final restaurant = menuProvider.restaurant;
        if (restaurant == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Restaurant data not found',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context, restaurant, cartProvider),
          body: Column(
            children: [
              // Quick Order Bar
              if (_sessionType == 'dine_in')
                QuickOrderBar(
                  items: menuProvider.quickOrderItems,
                  onItemTap: (item) => _addToCart(context, item, cartProvider),
                ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: SearchBarWidget(),
              ),

              // Category Tabs
              CategoryTabs(
                categories: menuProvider.categories,
                selectedCategory: menuProvider.selectedCategory,
                onCategorySelected: menuProvider.selectCategory,
              ),

              // Menu Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Menu Tab
                    _buildMenuContent(context, menuProvider, cartProvider),
                    // Cart Tab
                    CartScreen(
                      sessionId: _sessionId,
                      sessionType: _sessionType,
                      tableNumber: _tableNumber,
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(
            context,
            cartProvider,
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    restaurant,
    CartProvider cartProvider,
  ) {
    // Get values from widget or fallback to provider
    final displayName = widget.restaurantName ?? 
                       restaurant?.name ?? 
                       'Restaurant';
    final displayTable = widget.tableNumber ?? 
                        cartProvider.tableNumber ?? 
                        'Table';
    
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            displayTable,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
      actions: [
        // Cart Badge
        badges.Badge(
          badgeContent: Text(
            '${cartProvider.totalItems}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          badgeStyle: badges.BadgeStyle(
            badgeColor: AppColors.primary,
            padding: const EdgeInsets.all(6),
          ),
          child: IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => _tabController.animateTo(1),
          ),
        ),
        const SizedBox(width: 8),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(text: 'Menu', icon: Icon(Icons.restaurant_menu)),
          Tab(text: 'Cart', icon: Icon(Icons.shopping_cart)),
        ],
      ),
    );
  }

  Widget _buildMenuContent(
    BuildContext context,
    MenuProvider menuProvider,
    CartProvider cartProvider,
  ) {
    // If there's a search query, show search results instead
    if (menuProvider.searchQuery.isNotEmpty) {
      return _buildSearchResults(context, menuProvider, cartProvider);
    }

    // If a category is selected, show category items
    if (menuProvider.selectedCategory.isNotEmpty) {
      final categoryItems = menuProvider.getItemsByCategory(menuProvider.selectedCategory);
      return WebMenuGrid(
        items: categoryItems,
        onItemTap: (item) => _addToCart(context, item, cartProvider),
        onAddToCart: (item) => _addToCart(context, item, cartProvider),
        getItemQuantity: (id) => cartProvider.getItemQuantity(id),
        onDecrement: (item) => _decreaseItemQuantity(context, item, cartProvider),
      );
    }

    // Show menu sections
    return _buildMenuSections(context, menuProvider, cartProvider);
  }

  Widget _buildSearchResults(
    BuildContext context,
    MenuProvider menuProvider,
    CartProvider cartProvider,
  ) {
    if (menuProvider.menuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No items found for "${menuProvider.searchQuery}"',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultsScreen(
                      searchQuery: menuProvider.searchQuery,
                    ),
                  ),
                );
              },
              child: const Text('View All Search Results'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: menuProvider.clearSearch,
              child: const Text('Clear Search'),
            ),
          ],
        ),
      );
    }

    // Show search results with option to view all
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Search Results (${menuProvider.menuItems.length})',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchResultsScreen(
                        searchQuery: menuProvider.searchQuery,
                      ),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        Expanded(
          child: WebMenuGrid(
            items: menuProvider.menuItems.take(6).toList(), // Show first 6 results
            onItemTap: (item) => _addToCart(context, item, cartProvider),
            onAddToCart: (item) => _addToCart(context, item, cartProvider),
            getItemQuantity: (id) => cartProvider.getItemQuantity(id),
            onDecrement: (item) => _decreaseItemQuantity(context, item, cartProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSections(
    BuildContext context,
    MenuProvider menuProvider,
    CartProvider cartProvider,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Most Ordered section
          MenuSectionWidget(
            title: 'Most Ordered',
            items: menuProvider.popularItems,
            onAddToCart: (item) => _addToCart(context, item, cartProvider),
            getItemQuantity: (id) => cartProvider.getItemQuantity(id),
            onDecrement: (item) => _decreaseItemQuantity(context, item, cartProvider),
          ),

          // Category sections
          ...menuProvider.categories.map((category) {
            final categoryItems = menuProvider.getItemsByCategory(category);
            return MenuSectionWidget(
              title: category,
              items: categoryItems,
              onAddToCart: (item) => _addToCart(context, item, cartProvider),
              getItemQuantity: (id) => cartProvider.getItemQuantity(id),
              onDecrement: (item) => _decreaseItemQuantity(context, item, cartProvider),
            );
          }).toList(),

          const SizedBox(height: 100), // Space for floating action button
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    CartProvider cartProvider,
  ) {
    if (cartProvider.items.isEmpty) return null;

    return FloatingActionButton.extended(
      onPressed: () => _goToCheckout(context),
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.payment, color: Colors.white),
      label: Text(
        'Checkout (₹${cartProvider.totalAmount.toStringAsFixed(0)})',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _addToCart(
    BuildContext context,
    MenuItemModel item,
    CartProvider cartProvider,
  ) async {
    try {
      await cartProvider.addItem(item);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} added to cart'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _decreaseItemQuantity(
    BuildContext context,
    MenuItemModel item,
    CartProvider cartProvider,
  ) async {
    try {
      // Find the item index in cart
      final itemIndex = cartProvider.items.indexWhere(
        (cartItem) => cartItem.menuItem.id == item.id,
      );
      
      if (itemIndex != -1) {
        final currentQuantity = cartProvider.items[itemIndex].quantity;
        if (currentQuantity > 1) {
          await cartProvider.updateQuantity(itemIndex, currentQuantity - 1);
        } else {
          await cartProvider.removeItem(itemIndex);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _goToCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          sessionId: _sessionId,
          sessionType: _sessionType,
          tableNumber: _tableNumber,
        ),
      ),
    );
  }
}

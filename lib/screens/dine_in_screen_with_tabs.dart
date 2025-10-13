import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../models/menu_item_model.dart';
import '../services/firebase_service.dart';
import '../utils/app_theme.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/item_status_badge.dart';
import '../screens/your_order_screen.dart';
import 'checkout_screen.dart';

class DineInScreenWithTabs extends StatefulWidget {
  const DineInScreenWithTabs({super.key});

  @override
  State<DineInScreenWithTabs> createState() => _DineInScreenWithTabsState();
}

class _DineInScreenWithTabsState extends State<DineInScreenWithTabs>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _sessionId;
  String? _tableNumber;
  String? _code;
  StreamSubscription<DocumentSnapshot>? _sessionListener;
  
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _initializeSession();
  }

  void _initializeSession() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _sessionId = args['sessionId'];
        _tableNumber = args['tableNumber'];
        _code = args['code'];
        
        // Initialize cart provider with dine-in session
        context.read<CartProvider>().initializeSession(
          _sessionId!,
          'dine_in',
          tableNumber: _tableNumber,
        );
        
        // Load existing cart from Firebase
        context.read<CartProvider>().loadFromFirebase(_sessionId!, 'dine_in');
        
        // Initialize menu data
        context.read<MenuProvider>().initializeWithFirebaseData();
        
        // Set up real-time listener for session updates
        _setupSessionListener();
      }
    });
  }

  void _setupSessionListener() {
    if (_sessionId != null) {
      _sessionListener = FirebaseService.dineInSessions
          .doc(_sessionId)
          .snapshots()
          .listen((snapshot) {
        if (mounted && snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final status = data['status'] as String?;
          
          if (status == 'completed') {
            // Session completed, redirect to entry screen
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            );
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _sessionListener?.cancel();
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _addToCart(MenuItemModel item) {
    final cartProvider = context.read<CartProvider>();
    cartProvider.addItem(item);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _incrementItem(MenuItemModel item) {
    final cartProvider = context.read<CartProvider>();
    final itemIndex = cartProvider.items.indexWhere(
      (cartItem) => cartItem.menuItem.id == item.id && cartItem.status == ItemStatus.pending,
    );
    
    if (itemIndex >= 0) {
      cartProvider.increaseItemQuantity(itemIndex);
    } else {
      // Add new item if not found
      cartProvider.addItem(item);
    }
  }
  
  void _decrementItem(MenuItemModel item) {
    final cartProvider = context.read<CartProvider>();
    final itemIndex = cartProvider.items.indexWhere(
      (cartItem) => cartItem.menuItem.id == item.id && cartItem.status == ItemStatus.pending,
    );
    
    if (itemIndex >= 0) {
      cartProvider.decreaseItemQuantity(itemIndex);
    }
  }

  void _openCartDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartDrawer(
        sessionId: _sessionId!,
        sessionType: 'dine_in',
        tableNumber: _tableNumber,
        onCheckout: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckoutScreen(
              sessionId: _sessionId!,
              sessionType: 'dine_in',
              tableNumber: _tableNumber,
            ),
          ),
        ),
      ),
    );
  }

  void _callWaiter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.support_agent,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Call Waiter',
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'What can our waiter help you with?',
              style: TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                _buildWaiterOption(
                  icon: Icons.help_outline,
                  title: 'General Assistance',
                  subtitle: 'Need help with menu or recommendations',
                ),
                const SizedBox(height: 12),
                _buildWaiterOption(
                  icon: Icons.receipt_long,
                  title: 'Bill & Payment',
                  subtitle: 'Questions about your bill or payment',
                ),
                const SizedBox(height: 12),
                _buildWaiterOption(
                  icon: Icons.feedback_outlined,
                  title: 'Service Issue',
                  subtitle: 'Report a problem or concern',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaiterOption({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Waiter has been notified! They will be with you shortly.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariantDark.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.surfaceVariantDark.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textTertiaryDark,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            // Menu Tab
            _buildMenuTab(),
            // Your Order Tab
            if (_sessionId != null)
              YourOrderScreen(
                sessionId: _sessionId!,
                tableNumber: _tableNumber,
              )
            else
              const Center(child: CircularProgressIndicator()),
            // Call Waiter Tab (placeholder - action happens in bottom nav)
            Container(),
          ],
        ),
      ),
      
      // Floating Cart Button (only on menu tab)
      floatingActionButton: _currentIndex == 0 
          ? Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                if (cartProvider.itemCount == 0) return const SizedBox.shrink();
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 80),
                  child: FloatingActionButton.extended(
                    onPressed: _openCartDrawer,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    elevation: 8,
                    icon: Stack(
                      children: [
                        const Icon(Icons.shopping_cart),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cartProvider.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    label: Text(
                      '₹${cartProvider.grandTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(
                  icon: Icons.restaurant_menu,
                  label: 'Menu',
                  index: 0,
                  isSelected: _currentIndex == 0,
                ),
Consumer<CartProvider>(
                  builder: (context, cartProvider, _) {
                    final totalItems = cartProvider.sessionItems.length + cartProvider.itemCount;
                    return _buildBottomNavItem(
                      icon: Icons.receipt_long,
                      label: 'Your Order',
                      index: 1,
                      isSelected: _currentIndex == 1,
                      badge: totalItems > 0 ? totalItems : null,
                    );
                  },
                ),
                _buildBottomNavItem(
                  icon: Icons.support_agent,
                  label: 'Call Waiter',
                  index: 2,
                  isSelected: false, // This doesn't navigate, just calls action
                  onTap: _callWaiter,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    dynamic badge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.primary : AppColors.textSecondaryDark,
                  size: 24,
                ),
                if (badge != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondaryDark,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTab() {
    return Consumer2<MenuProvider, CartProvider>(
      builder: (context, menuProvider, cartProvider, child) {
        return CustomScrollView(
          slivers: [
            // Premium App Bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.8),
                        AppColors.secondary.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dine-In Experience',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (_tableNumber != null)
                                      Text(
                                        'Table $_tableNumber',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              'Real-time ordering • Live updates',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Menu Categories & Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search delicious dishes...',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondaryDark,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        style: TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Category Tabs
                    if (menuProvider.categories.isNotEmpty)
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: menuProvider.categories.length,
                          itemBuilder: (context, index) {
                            final category = menuProvider.categories[index];
                            final isSelected = category == menuProvider.selectedCategory;
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: FilterChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (selected) {
                                  menuProvider.selectCategory(
                                    selected ? category : '',
                                  );
                                },
                                backgroundColor: AppColors.surfaceDark,
                                selectedColor: AppColors.primary.withOpacity(0.2),
                                checkmarkColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondaryDark,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surfaceVariantDark,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Menu Items Grid
            if (menuProvider.filteredMenuItems.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: MediaQuery.of(context).size.width < 600 ? 0.75 : 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = menuProvider.filteredMenuItems[index];
                      return Consumer<CartProvider>(
                        builder: (context, cartProvider, _) {
                          final quantity = cartProvider.getItemQuantity(item.id);
                          return MenuItemCard(
                            item: item,
                            onAddToCart: () => _addToCart(item),
                            sessionType: 'dine_in',
                            quantity: quantity,
                            onIncrement: () => _incrementItem(item),
                            onDecrement: () => _decrementItem(item),
                          );
                        },
                      );
                    },
                    childCount: menuProvider.filteredMenuItems.length,
                  ),
                ),
              ),
            
            // Loading or Empty State
            if (menuProvider.isLoading)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Loading menu...',
                        style: TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            if (!menuProvider.isLoading && menuProvider.filteredMenuItems.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 64,
                        color: AppColors.textSecondaryDark,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No items found',
                        style: TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Bottom spacing for navigation
            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        );
      },
    );
  }
}
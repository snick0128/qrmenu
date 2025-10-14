import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qrmenu/widgets/menu_item_shimmer.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../models/menu_item_model.dart';
import '../services/firebase_service.dart';
import '../utils/app_theme.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/menu_item_card.dart';
import 'checkout_screen.dart';

class ParcelScreen extends StatefulWidget {
  const ParcelScreen({super.key});

  @override
  State<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends State<ParcelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _sessionId;
  Timer? _debounce;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<DocumentSnapshot>? _orderListener;
  String? _orderStatus;

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

  Future<void> _initializeSession() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _sessionId = args['sessionId'];
        final hotelId = args['hotelId'] as String?;

        // Initialize cart provider with parcel session
        context.read<CartProvider>().initializeSession(_sessionId!, 'parcel');

        // Load existing cart from Firebase
        context.read<CartProvider>().loadFromFirebase(_sessionId!, 'parcel');

        if (hotelId != null) {
          // Initialize menu data with hotel ID
          await context.read<MenuProvider>().initializeWithFirebaseData(
            hotelId,
          );
        } else {
          // Fallback to default restaurant
          await context.read<MenuProvider>().initializeWithMockData();
        }

        // Set up real-time listener for order updates
        _setupOrderListener(hotelId);
      }
    });
  }

  void _setupOrderListener(String? hotelId) {
    if (_sessionId != null) {
      CollectionReference ordersCollection;

      if (hotelId != null) {
        // Use restaurant's orders collection
        ordersCollection = FirebaseService.restaurants
            .doc(hotelId)
            .collection('orders');
      } else {
        // Fallback to old collection
        ordersCollection = FirebaseService.orders;
      }

      _orderListener = ordersCollection.doc(_sessionId).snapshots().listen((
        snapshot,
      ) {
        if (mounted && snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final status = data['status'] as String?;

          setState(() {
            _orderStatus = status;
          });

          if (status == 'completed') {
            // Show completion dialog
            _showOrderCompletedDialog();
          }
        }
      });
    }
  }

  void _showOrderCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 32),
            const SizedBox(width: 12),
            Text(
              'Order Completed!',
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your order has been completed and is ready for pickup.',
              style: TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.success),
                  const SizedBox(width: 12),
                  Text(
                    'Please collect from counter',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _orderListener?.cancel();
    _animationController.dispose();
    // cancel any pending debounce timer
    _debounce?.cancel();
    super.dispose();
  }

  void _addToCart(MenuItemModel item) {
    final cartProvider = context.read<CartProvider>();

    // Check if order is locked
    if (_orderStatus != null && _orderStatus != 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cannot add items once order is being prepared'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

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

    // Check if order is locked
    if (_orderStatus != null && _orderStatus != 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Cannot modify items once order is being prepared',
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final itemIndex = cartProvider.items.indexWhere(
      (cartItem) => cartItem.menuItem.id == item.id,
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

    // Check if order is locked
    if (_orderStatus != null && _orderStatus != 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Cannot modify items once order is being prepared',
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final itemIndex = cartProvider.items.indexWhere(
      (cartItem) => cartItem.menuItem.id == item.id,
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
        sessionType: 'parcel',
        onCheckout: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CheckoutScreen(sessionId: _sessionId!, sessionType: 'parcel'),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return AppColors.statusPending;
      case 'preparing':
        return AppColors.statusPreparing;
      case 'ready':
        return AppColors.statusServed;
      case 'completed':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'Order Placed';
      case 'preparing':
        return 'Being Prepared';
      case 'ready':
        return 'Ready for Pickup';
      case 'completed':
        return 'Completed';
      default:
        return 'Active';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundDark,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedPadding(
          // push the content up when keyboard appears so the search field isn't overlapped
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          duration: const Duration(milliseconds: 200),
          child: Consumer2<MenuProvider, CartProvider>(
            builder: (context, menuProvider, cartProvider, child) {
              return CustomScrollView(
                slivers: [
                  // Premium App Bar
                  SliverAppBar(
                    expandedHeight: 240,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary.withOpacity(0.8),
                              AppColors.primary.withOpacity(0.6),
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
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.glassDark,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppColors.glassDark
                                              .withOpacity(0.75),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.takeout_dining,
                                        color: AppColors.textPrimaryDark,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Parcel Order',
                                            style: TextStyle(
                                              color: AppColors.textPrimaryDark,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Quick takeaway service',
                                            style: TextStyle(
                                              color:
                                                  AppColors.textSecondaryDark,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Order Status Card
                                if (_orderStatus != null)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.glassDark.withOpacity(
                                        0.375,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _getStatusColor(
                                          _orderStatus,
                                        ).withOpacity(0.5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              _orderStatus,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _getStatusText(_orderStatus),
                                          style: TextStyle(
                                            color: AppColors.textPrimaryDark,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (_orderStatus == 'preparing' ||
                                            _orderStatus == 'ready')
                                          Icon(
                                            Icons.access_time,
                                            color: AppColors.textSecondaryDark,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                  ),

                                if (_orderStatus == null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.glassDark,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.glassDark.withOpacity(
                                          0.75,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Order once locked • Online payment only',
                                      style: TextStyle(
                                        color: AppColors.textPrimaryDark,
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
                                  color: AppColors.cardShadowDark,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              onChanged: (value) {
                                final q = value.trim();
                                if (_debounce?.isActive ?? false)
                                  _debounce!.cancel();
                                _debounce = Timer(
                                  const Duration(milliseconds: 500),
                                  () {
                                    // set empty query to clear filters
                                    context.read<MenuProvider>().setSearchQuery(
                                      q,
                                    );
                                  },
                                );
                              },
                              decoration: InputDecoration(
                                hintText: 'Search quick bites...',
                                hintStyle: TextStyle(
                                  color: AppColors.textSecondaryDark,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppColors.secondary,
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
                                  final category =
                                      menuProvider.categories[index];
                                  final isSelected =
                                      category == menuProvider.selectedCategory;

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
                                      selectedColor: AppColors.secondary
                                          .withOpacity(0.2),
                                      checkmarkColor: AppColors.secondary,
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? AppColors.secondary
                                            : AppColors.textSecondaryDark,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                      side: BorderSide(
                                        color: isSelected
                                            ? AppColors.secondary
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

                  if (menuProvider.isLoading)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width < 600
                              ? 2
                              : MediaQuery.of(context).size.width < 900
                              ? 3
                              : 4,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio:
                              MediaQuery.of(context).size.width < 600
                              ? 0.75
                              : 0.8,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return const MenuItemShimmer();
                        }, childCount: 6),
                      ),
                    ),

                  if (!menuProvider.isLoading &&
                      menuProvider.filteredMenuItems.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width < 600
                              ? 2
                              : MediaQuery.of(context).size.width < 900
                              ? 3
                              : 4,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio:
                              MediaQuery.of(context).size.width < 600
                              ? 0.75
                              : 0.8,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = menuProvider.filteredMenuItems[index];
                          return Consumer<CartProvider>(
                            builder: (context, cartProvider, _) {
                              final quantity = cartProvider.getItemQuantity(
                                item.id,
                              );
                              return MenuItemCard(
                                item: item,
                                onAddToCart: () => _addToCart(item),
                                sessionType: 'parcel',
                                quantity: quantity,
                                onIncrement: () => _incrementItem(item),
                                onDecrement: () => _decrementItem(item),
                              );
                            },
                          );
                        }, childCount: menuProvider.filteredMenuItems.length),
                      ),
                    ),

                  // Empty State
                  if (!menuProvider.isLoading &&
                      menuProvider.filteredMenuItems.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.takeout_dining,
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

                  // Bottom spacing for cart button
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),
      ),

      // Floating Cart Button
      floatingActionButton: Builder(
        builder: (context) {
          final cartProvider = context.watch<CartProvider>();
          if (cartProvider.itemCount == 0) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: FloatingActionButton.extended(
              onPressed: _openCartDrawer,
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              elevation: 8,
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_bag),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cartProvider.itemCount}',
                        style: const TextStyle(
                          color: Colors.black,
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

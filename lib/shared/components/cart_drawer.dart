import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item_model.dart';
import '../utils/app_theme.dart';
import '../widgets/item_status_badge.dart';

class CartDrawer extends StatefulWidget {
  final String sessionId;
  final String sessionType;
  final String? tableNumber;
  final VoidCallback onCheckout;

  const CartDrawer({
    super.key,
    required this.sessionId,
    required this.sessionType,
    this.tableNumber,
    required this.onCheckout,
  });

  @override
  State<CartDrawer> createState() => _CartDrawerState();
}

class _CartDrawerState extends State<CartDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeDrawer() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  bool _canModifyItem(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return true; // Can add, remove, increase, decrease
      case 'preparing':
        return widget.sessionType == 'dine_in'; // Can only increase for dine-in
      case 'served':
        return false; // Can only reorder
      default:
        return false;
    }
  }

  bool _canReorderItem(String status) {
    return status.toLowerCase() == 'served';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Background overlay
            FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: _closeDrawer,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

            // Cart drawer
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOut,
                      ),
                    ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textTertiaryDark,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Header
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                widget.sessionType == 'dine_in'
                                    ? Icons.restaurant_menu
                                    : Icons.takeout_dining,
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
                                    widget.sessionType == 'dine_in'
                                        ? 'Your Order'
                                        : 'Parcel Order',
                                    style: TextStyle(
                                      color: AppColors.textPrimaryDark,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (widget.tableNumber != null)
                                    Text(
                                      'Table ${widget.tableNumber}',
                                      style: TextStyle(
                                        color: AppColors.textSecondaryDark,
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _closeDrawer,
                              icon: Icon(
                                Icons.close,
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Cart items
                      Expanded(
                        child: Consumer<CartProvider>(
                          builder: (context, cartProvider, child) {
                            if (cartProvider.items.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 64,
                                      color: AppColors.textTertiaryDark,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Your cart is empty',
                                      style: TextStyle(
                                        color: AppColors.textSecondaryDark,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add some delicious items to get started',
                                      style: TextStyle(
                                        color: AppColors.textTertiaryDark,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              itemCount: cartProvider.items.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final item = cartProvider.items[index];
                                return _CartItemCard(
                                  item: item.toCartItemModel(),
                                  sessionType: widget.sessionType,
                                  onIncrease:
                                      _canModifyItem(
                                        item.status?.name ?? 'pending',
                                      )
                                      ? () => cartProvider.increaseItemQuantity(
                                          index,
                                        )
                                      : null,
                                  onDecrease:
                                      _canModifyItem(
                                        item.status?.name ?? 'pending',
                                      )
                                      ? () => cartProvider.decreaseItemQuantity(
                                          index,
                                        )
                                      : null,
                                  onRemove:
                                      _canModifyItem(
                                        item.status?.name ?? 'pending',
                                      )
                                      ? () => cartProvider.removeItem(index)
                                      : null,
                                  onReorder:
                                      _canReorderItem(
                                        item.status?.name ?? 'pending',
                                      )
                                      ? () => cartProvider.reorderItem(index)
                                      : null,
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Bottom summary and checkout
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDark,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          top: false,
                          child: Consumer<CartProvider>(
                            builder: (context, cartProvider, child) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Order summary
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total (${cartProvider.itemCount} items)',
                                        style: TextStyle(
                                          color: AppColors.textSecondaryDark,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '₹${cartProvider.grandTotal.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // Action buttons for dine-in vs parcel
                                  if (widget.sessionType == 'dine_in')
                                    // Dine-in: Place Order (adds to session)
                                    Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: cartProvider.items.isEmpty
                                              ? null
                                              : () async {
                                                  try {
                                                    await cartProvider
                                                        .placeOrder();
                                                    _closeDrawer();
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Order sent to kitchen! Continue browsing menu.',
                                                          ),
                                                          backgroundColor:
                                                              AppColors.success,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Error placing order: $e',
                                                        ),
                                                        backgroundColor:
                                                            AppColors.error,
                                                      ),
                                                    );
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            elevation: 8,
                                            shadowColor: AppColors.primary
                                                .withOpacity(0.4),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.restaurant, size: 20),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Send to Kitchen',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    // Parcel: Direct to payment
                                    ElevatedButton(
                                      onPressed: cartProvider.items.isEmpty
                                          ? null
                                          : () {
                                              _closeDrawer();
                                              widget.onCheckout();
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        elevation: 8,
                                        shadowColor: AppColors.primary
                                            .withOpacity(0.4),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.payment, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Proceed to Payment',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final String sessionType;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onRemove;
  final VoidCallback? onReorder;

  const _CartItemCard({
    required this.item,
    required this.sessionType,
    this.onIncrease,
    this.onDecrease,
    this.onRemove,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.surfaceVariantDark.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item header with status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${item.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              if (item.status != null) ItemStatusBadge(status: item.status!),

              // Counter badge if no status
              if (item.addedByCounter == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info.withOpacity(0.5)),
                  ),
                  child: Text(
                    'Added by Counter',
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Quantity controls and actions
          Row(
            children: [
              // Quantity controls
              if (onDecrease != null || onIncrease != null)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariantDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Decrease button
                      GestureDetector(
                        onTap: onDecrease,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.remove,
                            color: onDecrease != null
                                ? AppColors.textPrimaryDark
                                : AppColors.textTertiaryDark,
                            size: 18,
                          ),
                        ),
                      ),

                      // Quantity
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: TextStyle(
                            color: AppColors.textPrimaryDark,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Increase button
                      GestureDetector(
                        onTap: onIncrease,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.add,
                            color: onIncrease != null
                                ? AppColors.primary
                                : AppColors.textTertiaryDark,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // If no quantity controls available, show quantity
              if (onDecrease == null && onIncrease == null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariantDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Qty: ${item.quantity}',
                    style: TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              const Spacer(),

              // Action buttons
              Row(
                children: [
                  // Reorder button
                  if (onReorder != null)
                    GestureDetector(
                      onTap: onReorder,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh,
                              color: AppColors.success,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Reorder',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Remove button
                  if (onRemove != null) ...[
                    if (onReorder != null) const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 16,
                        ),
                      ),
                    ),
                  ],

                  // Total price
                  const SizedBox(width: 12),
                  Text(
                    '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

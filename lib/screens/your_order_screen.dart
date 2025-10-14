import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/item_status_badge.dart';
import '../screens/checkout_screen.dart';

class YourOrderScreen extends StatefulWidget {
  final String sessionId;
  final String? tableNumber;

  const YourOrderScreen({super.key, required this.sessionId, this.tableNumber});

  @override
  State<YourOrderScreen> createState() => _YourOrderScreenState();
}

class _YourOrderScreenState extends State<YourOrderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _completeSession() async {
    final cartProvider = context.read<CartProvider>();

    if (cartProvider.sessionItems.isEmpty && cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No items ordered yet!'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          sessionId: widget.sessionId,
          sessionType: 'dine_in',
          tableNumber: widget.tableNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            final allItems = [
              ...cartProvider.sessionItems,
              ...cartProvider.items,
            ];
            final sessionTotal = cartProvider.sessionItems.fold(
              0.0,
              (sum, item) => sum + item.totalPrice,
            );
            final currentCartTotal = cartProvider.totalAmount;
            final grandTotal = sessionTotal + currentCartTotal;

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  backgroundColor: AppColors.surfaceDark,
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
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.receipt_long,
                                      color: Colors.white,
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
                                          'Your Order',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (widget.tableNumber != null)
                                          Text(
                                            'Table ${widget.tableNumber}',
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
                                  allItems.isEmpty
                                      ? 'No items ordered yet'
                                      : '${allItems.length} items • ₹${grandTotal.toStringAsFixed(0)}',
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

                // Order Items
                if (allItems.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.surfaceVariantDark.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Session Items (Already sent to kitchen)
                          if (cartProvider.sessionItems.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sent to Kitchen',
                                  style: TextStyle(
                                    color: AppColors.textPrimaryDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '₹${sessionTotal.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...cartProvider.sessionItems.map(
                              (item) => _buildOrderItem(item, true),
                            ),
                            if (cartProvider.items.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Divider(color: AppColors.surfaceVariantDark),
                              const SizedBox(height: 16),
                            ],
                          ],

                          // Current Cart Items (Pending to be sent)
                          if (cartProvider.items.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.pending,
                                  color: AppColors.warning,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'In Cart (Pending)',
                                  style: TextStyle(
                                    color: AppColors.textPrimaryDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '₹${currentCartTotal.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...cartProvider.items.map(
                              (item) => _buildOrderItem(item, false),
                            ),
                          ],

                          // Total
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    color: AppColors.textPrimaryDark,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '₹${grandTotal.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Empty State
                if (allItems.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 80,
                            color: AppColors.textTertiaryDark,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No orders yet',
                            style: TextStyle(
                              color: AppColors.textSecondaryDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start browsing the menu to add items',
                            style: TextStyle(
                              color: AppColors.textTertiaryDark,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Complete Session Button (Fixed at bottom when items exist)
                if (allItems.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: _completeSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primary.withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payment, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Complete Session & Pay',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderItem(CartItem item, bool isSentToKitchen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSentToKitchen
            ? AppColors.success.withOpacity(0.05)
            : AppColors.warning.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSentToKitchen
              ? AppColors.success.withOpacity(0.2)
              : AppColors.warning.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuItem.name,
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity} × ₹${item.menuItem.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 14,
                  ),
                ),
                if (item.specialInstructions != null &&
                    item.specialInstructions!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Note: ${item.specialInstructions}',
                    style: TextStyle(
                      color: AppColors.textTertiaryDark,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isSentToKitchen) ItemStatusBadge(status: item.status.name),
              const SizedBox(height: 8),
              Text(
                '₹${item.totalPrice.toStringAsFixed(0)}',
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
    );
  }
}

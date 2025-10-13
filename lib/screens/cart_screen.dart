import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../utils/app_theme.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final String? sessionId;
  final String? sessionType;
  final String? tableNumber;

  const CartScreen({
    super.key,
    this.sessionId,
    this.sessionType,
    this.tableNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, MenuProvider>(
      builder: (context, cartProvider, menuProvider, child) {
        if (cartProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cartProvider.items.isEmpty) {
          return _buildEmptyCart(context);
        }

        return Column(
          children: [
            // Session Info Header
            if (sessionType == 'dine_in' && tableNumber != null)
              _buildSessionHeader(context, tableNumber!),
            
            // Cart Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Pending Items
                  if (cartProvider.pendingItems.isNotEmpty)
                    _buildStatusSection(
                      context,
                      'Pending Orders',
                      cartProvider.pendingItems,
                      cartProvider,
                      ItemStatus.pending,
                    ),
                  
                  // Preparing Items
                  if (cartProvider.preparingItems.isNotEmpty)
                    _buildStatusSection(
                      context,
                      'Preparing',
                      cartProvider.preparingItems,
                      cartProvider,
                      ItemStatus.preparing,
                    ),
                  
                  // Served Items
                  if (cartProvider.servedItems.isNotEmpty)
                    _buildStatusSection(
                      context,
                      'Served',
                      cartProvider.servedItems,
                      cartProvider,
                      ItemStatus.served,
                    ),
                ],
              ),
            ),
            
            // Order Summary
            _buildOrderSummary(context, cartProvider),
          ],
        );
      },
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some delicious items to get started!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionHeader(BuildContext context, String tableNumber) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.table_restaurant,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Table $tableNumber',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'DINE-IN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(
    BuildContext context,
    String title,
    List<CartItem> items,
    CartProvider cartProvider,
    ItemStatus status,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _getStatusIcon(status),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(status),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildCartItem(context, index, item, cartProvider, status);
        }).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    int index,
    CartItem item,
    CartProvider cartProvider,
    ItemStatus status,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Header
          Row(
            children: [
              Expanded(
                child: Text(
                  item.menuItem.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '₹${item.totalPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          
          // Special Instructions
          if (item.specialInstructions != null && item.specialInstructions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Note: ${item.specialInstructions}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          
          // Quantity Controls
          const SizedBox(height: 12),
          Row(
            children: [
              // Quantity Label
              Text(
                'Quantity: ',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              
              // Quantity Controls
              if (_canModifyQuantity(status, item))
                Row(
                  children: [
                    _buildQuantityButton(
                      context,
                      index,
                      item,
                      cartProvider,
                      Icons.remove,
                      () => cartProvider.updateQuantity(index, item.quantity - 1),
                    ),
                    Container(
                      width: 40,
                      height: 32,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    _buildQuantityButton(
                      context,
                      index,
                      item,
                      cartProvider,
                      Icons.add,
                      () => cartProvider.updateQuantity(index, item.quantity + 1),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.quantity}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              
              const Spacer(),
              
              // Action Buttons
              if (status == ItemStatus.served)
                ElevatedButton.icon(
                  onPressed: () => cartProvider.reorderItem(index),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reorder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                )
              else if (status == ItemStatus.pending)
                IconButton(
                  onPressed: () => cartProvider.removeItem(index),
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(
    BuildContext context,
    int index,
    CartItem item,
    CartProvider cartProvider,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: Colors.white),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Items:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${cartProvider.totalItems}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '₹${cartProvider.totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              if (!cartProvider.isOrderPlaced && cartProvider.pendingItems.isNotEmpty)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => cartProvider.placeOrder(),
                    icon: const Icon(Icons.check),
                    label: const Text('Place Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              
              if (cartProvider.isOrderPlaced || cartProvider.pendingItems.isEmpty)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _goToCheckout(context),
                    icon: const Icon(Icons.payment),
                    label: const Text('Checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canModifyQuantity(ItemStatus status, CartItem item) {
    switch (status) {
      case ItemStatus.pending:
        return true;
      case ItemStatus.preparing:
        return true; // Can only increase
      case ItemStatus.served:
        return false;
    }
  }

  Icon _getStatusIcon(ItemStatus status) {
    switch (status) {
      case ItemStatus.pending:
        return Icon(Icons.access_time, color: AppColors.warning, size: 20);
      case ItemStatus.preparing:
        return Icon(Icons.restaurant, color: AppColors.info, size: 20);
      case ItemStatus.served:
        return Icon(Icons.check_circle, color: AppColors.success, size: 20);
    }
  }

  Color _getStatusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.pending:
        return AppColors.warning;
      case ItemStatus.preparing:
        return AppColors.info;
      case ItemStatus.served:
        return AppColors.success;
    }
  }

  void _goToCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          sessionId: sessionId,
          sessionType: sessionType,
          tableNumber: tableNumber,
        ),
      ),
    );
  }
}
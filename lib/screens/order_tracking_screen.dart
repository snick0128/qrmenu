import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_language_provider.dart';
import '../models/cart_item_model.dart';
import '../utils/app_theme.dart';
// Removed order_type_screen.dart as it was obsolete
import '../services/payment_service.dart';
import '../screens/feedback_screen.dart';
import '../screens/menu_screen.dart';

enum OrderStatus { pending, preparing, ready, served }
enum OrderType { dineIn, takeaway, delivery } // Temporary enum for compilation

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final List<CartItemModel> orderItems;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final OrderType orderType;
  final String? deliveryAddress;
  final String? paymentStatus;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.orderItems,
    required this.totalAmount,
    required this.paymentMethod,
    required this.orderType,
    this.deliveryAddress,
    this.paymentStatus = 'pending',
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  OrderStatus currentStatus = OrderStatus.pending;
  late Timer _statusTimer;
  DateTime orderPlacedTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startStatusSimulation();
  }

  @override
  void dispose() {
    _statusTimer.cancel();
    super.dispose();
  }

  void _startStatusSimulation() {
    // Auto-advance status every 30 seconds for demo
    _statusTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          switch (currentStatus) {
            case OrderStatus.pending:
              currentStatus = OrderStatus.preparing;
              break;
            case OrderStatus.preparing:
              currentStatus = OrderStatus.ready;
              break;
            case OrderStatus.ready:
              currentStatus = OrderStatus.served;
              _statusTimer.cancel(); // Stop when served
              break;
            case OrderStatus.served:
              break;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<AppLanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(languageProvider.getText('order_tracking')),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context, languageProvider),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order placed success message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    languageProvider.getText('order_placed'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Payment: ${widget.paymentStatus?.toUpperCase() ?? 'PENDING'}',
                    style: TextStyle(
                      color: widget.paymentStatus?.toLowerCase() == 'completed'
                          ? AppColors.success
                          : widget.paymentStatus?.toLowerCase() == 'failed'
                          ? AppColors.error
                          : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${languageProvider.getText('order_id')}: #${widget.orderId}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Order details
            _buildOrderDetailsSection(context, languageProvider),

            const SizedBox(height: 32),

            // Order status tracking
            _buildOrderStatusSection(context, languageProvider),

            const SizedBox(height: 32),

            // Manual status advance buttons (for demo)
            if (currentStatus != OrderStatus.served)
              _buildManualControlsSection(context, languageProvider),
          ],
        ),
      ),
      bottomNavigationBar: currentStatus == OrderStatus.served
          ? _buildCompletedActions(context, languageProvider)
          : null,
    );
  }

  Widget _buildOrderDetailsSection(
    BuildContext context,
    AppLanguageProvider languageProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                languageProvider.getText('order_summary'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getOrderTypeColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getOrderTypeText(languageProvider),
                  style: TextStyle(
                    color: _getOrderTypeColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Order items
          ...widget.orderItems
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: item.menuItem.isVeg
                              ? AppColors.veg
                              : AppColors.nonVeg,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.menuItem.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        'x${item.quantity}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '₹${item.totalPrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),

          const Divider(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                languageProvider.getText('total'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${widget.totalAmount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                languageProvider.getText('payment_method'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.paymentMethod == PaymentMethod.online ? 'UPI' : 'Cash',
                  style: TextStyle(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          if (widget.deliveryAddress != null) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${languageProvider.getText('delivery_address')}: ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.deliveryAddress!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderStatusSection(
    BuildContext context,
    AppLanguageProvider languageProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.getText('track_your_order'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          // Status timeline
          Column(
            children: [
              _buildStatusItem(
                context,
                languageProvider,
                OrderStatus.pending,
                Icons.restaurant,
                languageProvider.getText('pending'),
                languageProvider.getText('order_received'),
                0,
              ),
              _buildStatusItem(
                context,
                languageProvider,
                OrderStatus.preparing,
                Icons.restaurant_menu,
                languageProvider.getText('preparing'),
                languageProvider.getText('being_prepared'),
                1,
              ),
              _buildStatusItem(
                context,
                languageProvider,
                OrderStatus.ready,
                Icons.check_circle,
                languageProvider.getText('ready'),
                languageProvider.getText('order_ready'),
                2,
              ),
              _buildStatusItem(
                context,
                languageProvider,
                OrderStatus.served,
                widget.orderType == OrderType.delivery
                    ? Icons.delivery_dining
                    : Icons.dining,
                widget.orderType == OrderType.delivery
                    ? languageProvider.getText('delivered')
                    : languageProvider.getText('served'),
                languageProvider.getText('order_completed'),
                3,
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Estimated time
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getEstimatedTime(languageProvider),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    AppLanguageProvider languageProvider,
    OrderStatus status,
    IconData icon,
    String title,
    String subtitle,
    int index, {
    bool isLast = false,
  }) {
    final isCompleted = currentStatus.index >= status.index;
    final isActive = currentStatus == status;

    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
                border: isActive
                    ? Border.all(color: AppColors.primary, width: 3)
                    : null,
              ),
              child: Icon(
                icon,
                color: isCompleted ? Colors.white : AppColors.textTertiary,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isCompleted
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
                if (isActive)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualControlsSection(
    BuildContext context,
    AppLanguageProvider languageProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Demo Controls',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Simulate order progress (auto-advances every 30 seconds)',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _advanceStatus(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
              ),
              child: Text('Advance to ${_getNextStatusText()}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedActions(
    BuildContext context,
    AppLanguageProvider languageProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _navigateToFeedback(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(languageProvider.getText('rate_order')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _returnToMenu(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(languageProvider.getText('continue_browsing')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _advanceStatus() {
    if (currentStatus.index < OrderStatus.values.length - 1) {
      setState(() {
        currentStatus = OrderStatus.values[currentStatus.index + 1];
      });

      if (currentStatus == OrderStatus.served) {
        _statusTimer.cancel();
      }
    }
  }

  String _getNextStatusText() {
    switch (currentStatus) {
      case OrderStatus.pending:
        return 'Preparing';
      case OrderStatus.preparing:
        return 'Ready';
      case OrderStatus.ready:
        return 'Served';
      case OrderStatus.served:
        return 'Completed';
    }
  }

  Color _getOrderTypeColor() {
    switch (widget.orderType) {
      case OrderType.dineIn:
        return AppColors.primary;
      case OrderType.takeaway:
        return AppColors.secondary;
      case OrderType.delivery:
        return AppColors.info;
    }
  }

  String _getOrderTypeText(AppLanguageProvider languageProvider) {
    switch (widget.orderType) {
      case OrderType.dineIn:
        return languageProvider.getText('dine_in');
      case OrderType.takeaway:
        return languageProvider.getText('takeaway');
      case OrderType.delivery:
        return languageProvider.getText('delivery');
    }
  }

  String _getEstimatedTime(AppLanguageProvider languageProvider) {
    final elapsed = DateTime.now().difference(orderPlacedTime).inMinutes;

    switch (currentStatus) {
      case OrderStatus.pending:
        return 'Estimated time: 25-30 minutes';
      case OrderStatus.preparing:
        return 'Estimated time: ${20 - elapsed} minutes';
      case OrderStatus.ready:
        return 'Order is ready for pickup!';
      case OrderStatus.served:
        return 'Order completed successfully!';
    }
  }

  void _navigateToFeedback(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FeedbackScreen(
          orderId: widget.orderId,
          orderItems: widget.orderItems,
        ),
      ),
    );
  }

  void _returnToMenu(BuildContext context) {
    // Use go_router to navigate to root
    // This will trigger the routing logic to validate and show appropriate screen
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _showExitDialog(
    BuildContext context,
    AppLanguageProvider languageProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Order Tracking?'),
        content: const Text(
          'You can always return to track your order from the order history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(languageProvider.getText('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _returnToMenu(context);
            },
            child: Text(languageProvider.getText('continue_browsing')),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/item_status_badge.dart';
import '../services/firebase_service.dart';

class ParcelOrderStatusScreen extends StatefulWidget {
  final String orderId;
  final String? counterNumber;

  const ParcelOrderStatusScreen({
    super.key,
    required this.orderId,
    this.counterNumber,
  });

  @override
  State<ParcelOrderStatusScreen> createState() =>
      _ParcelOrderStatusScreenState();
}

class _ParcelOrderStatusScreenState extends State<ParcelOrderStatusScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  StreamSubscription<DocumentSnapshot>? _orderListener;
  Map<String, dynamic>? _orderData;
  String? _orderStatus;
  List<dynamic> _orderItems = [];
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _setupOrderListener();
  }

  void _setupOrderListener() {
    _orderListener = FirebaseService.orders
        .doc(widget.orderId)
        .snapshots()
        .listen((snapshot) {
          if (mounted && snapshot.exists) {
            setState(() {
              _orderData = snapshot.data() as Map<String, dynamic>;
              _orderStatus = _orderData!['status'] as String?;
              _orderItems = _orderData!['items'] as List<dynamic>? ?? [];
              _totalAmount =
                  (_orderData!['totalAmount'] as num?)?.toDouble() ?? 0.0;
            });

            // Handle order completion
            if (_orderStatus == 'completed') {
              _showOrderCompletedDialog();
            }

            // Start pulse animation for active states
            if (_orderStatus == 'preparing' || _orderStatus == 'ready') {
              _pulseController.repeat(reverse: true);
            } else {
              _pulseController.stop();
            }
          }
        });
  }

  @override
  void dispose() {
    _orderListener?.cancel();
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
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
              'Order Picked Up!',
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
              'Thank you for choosing us! Your order has been successfully picked up.',
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
                  Icon(Icons.star, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'We hope you enjoyed your meal! Please come again.',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
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
        return 'Processing';
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'pending':
        return Icons.receipt_long;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.hourglass_empty;
    }
  }

  Widget _buildProgressIndicator() {
    final statuses = ['pending', 'preparing', 'ready', 'completed'];
    final currentIndex = statuses.indexOf(_orderStatus ?? 'pending');

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.surfaceVariantDark.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Order Progress',
            style: TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: statuses.asMap().entries.map((entry) {
              final index = entry.key;
              final status = entry.value;
              final isActive = index <= currentIndex;
              final isCurrent = index == currentIndex;

              return Expanded(
                child: Row(
                  children: [
                    // Status circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isActive
                            ? _getStatusColor(status)
                            : AppColors.surfaceVariantDark,
                        shape: BoxShape.circle,
                        border: isCurrent
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      child:
                          isCurrent &&
                              (_orderStatus == 'preparing' ||
                                  _orderStatus == 'ready')
                          ? AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Icon(
                                    _getStatusIcon(status),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                );
                              },
                            )
                          : Icon(
                              _getStatusIcon(status),
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textTertiaryDark,
                              size: 20,
                            ),
                    ),

                    // Connection line (except for last item)
                    if (index < statuses.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isActive && index < currentIndex
                              ? _getStatusColor(statuses[index + 1])
                              : AppColors.surfaceVariantDark,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Placed',
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 12,
                ),
              ),
              Text(
                'Preparing',
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 12,
                ),
              ),
              Text(
                'Ready',
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 12,
                ),
              ),
              Text(
                'Done',
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.surfaceDark,
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
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Icon(
                                  Icons.takeout_dining,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Parcel Order',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (widget.counterNumber != null)
                                      Text(
                                        'Counter ${widget.counterNumber}',
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
                              color: _getStatusColor(
                                _orderStatus,
                              ).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _getStatusText(_orderStatus),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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

            // Progress Indicator
            SliverToBoxAdapter(child: _buildProgressIndicator()),

            // Order Items
            if (_orderItems.isNotEmpty)
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
                      Row(
                        children: [
                          Icon(
                            Icons.receipt,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Order Details',
                            style: TextStyle(
                              color: AppColors.textPrimaryDark,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_orderItems.length} items',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._orderItems.map((item) => _buildOrderItem(item)),
                      const SizedBox(height: 16),
                      Divider(color: AppColors.surfaceVariantDark),
                      const SizedBox(height: 16),
                      Row(
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
                            '₹${_totalAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Pickup Instructions (when ready)
            if (_orderStatus == 'ready')
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.success,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ready for Pickup!',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please visit the counter to collect your order.',
                        style: TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.counterNumber != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Counter ${widget.counterNumber}',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.surfaceVariantDark.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item['quantity']} × ₹${(item['price'] as num?)?.toStringAsFixed(0) ?? '0'}',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 14,
                  ),
                ),
                if (item['specialInstructions'] != null &&
                    (item['specialInstructions'] as String).isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Note: ${item['specialInstructions']}',
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
              ItemStatusBadge(status: item['status'] ?? 'pending'),
              const SizedBox(height: 8),
              Text(
                '₹${(((item['price'] as num?) ?? 0) * ((item['quantity'] as num?) ?? 1)).toStringAsFixed(0)}',
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

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/menu_item_model.dart';
import '../utils/app_theme.dart';
import 'menu_item_preview_modal.dart';

class MenuItemCard extends StatefulWidget {
  final MenuItemModel item;
  final VoidCallback onAddToCart;
  final String sessionType;
  final bool isLocked;
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.onAddToCart,
    required this.sessionType,
    this.isLocked = false,
    this.quantity = 0,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showPreview() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => MenuItemPreviewModal(
        item: widget.item,
        onAddToCart: () {
          Navigator.pop(context);
          widget.onAddToCart();
        },
        quantity: widget.quantity,
        onIncrement: () {
          widget.onIncrement?.call();
        },
        onDecrement: () {
          widget.onDecrement?.call();
        },
        isLocked: widget.isLocked,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen info for responsive text sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1200;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) {
              _animationController.reverse();
              _showPreview();
            },
            onTapCancel: () => _animationController.reverse(),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: AppColors.surfaceVariantDark.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    // Image Section - Takes ~60% of available space
                    Expanded(
                      flex: 6,
                      child: Stack(
                        children: [
                          // Main Image
                          Positioned.fill(
                            child: widget.item.imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: widget.item.imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        _buildImagePlaceholder(),
                                    errorWidget: (context, url, error) =>
                                        _buildImagePlaceholder(),
                                  )
                                : _buildImagePlaceholder(),
                          ),

                          // Gradient Overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.3),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),

                          // Top Indicators Row
                          Positioned(
                            top: 6,
                            left: 6,
                            right: 6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Veg/Non-veg indicator
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.circle,
                                    color: widget.item.isVeg
                                        ? AppColors.veg
                                        : AppColors.nonVeg,
                                    size: 6,
                                  ),
                                ),

                                // Popular badge
                                if (widget.item.isPopular)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'POPULAR',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: isDesktop ? 7 : 6,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Spicy indicator (bottom right of image)
                          if (widget.item.isSpicy)
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.spicy,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  Icons.local_fire_department,
                                  color: Colors.white,
                                  size: isDesktop ? 10 : 8,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Content Section - Takes ~40% of available space
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.all(
                          isDesktop ? 12 : (isTablet ? 10 : 8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Title and Price - Flexible to prevent overflow
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.item.name,
                                    style: TextStyle(
                                      color: AppColors.textPrimaryDark,
                                      fontSize: isDesktop
                                          ? 14
                                          : (isTablet ? 13 : 12),
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: isDesktop ? 4 : 2),
                                  Text(
                                    '₹${widget.item.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: isDesktop
                                          ? 16
                                          : (isTablet ? 14 : 13),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Action Button - Fixed height but responsive
                            SizedBox(height: isDesktop ? 6 : 4),
                            SizedBox(
                              height: isDesktop ? 32 : (isTablet ? 28 : 24),
                              child: widget.quantity > 0
                                  ? _buildQuantityControls(isDesktop, isTablet)
                                  : _buildAddButton(isDesktop, isTablet),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.secondary.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.restaurant_menu, color: AppColors.primary, size: 32),
      ),
    );
  }

  Widget _buildQuantityControls([
    bool isDesktop = false,
    bool isTablet = false,
  ]) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(
          isDesktop ? 16 : (isTablet ? 14 : 12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Decrement button
          Expanded(
            child: GestureDetector(
              onTap: widget.onDecrement,
              child: Center(
                child: Icon(
                  Icons.remove,
                  color: Colors.black,
                  size: isDesktop ? 16 : (isTablet ? 14 : 12),
                ),
              ),
            ),
          ),

          // Quantity display
          Container(
            width: isDesktop ? 32 : (isTablet ? 28 : 24),
            child: Center(
              child: Text(
                '${widget.quantity}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isDesktop ? 13 : (isTablet ? 12 : 11),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Increment button
          Expanded(
            child: GestureDetector(
              onTap: widget.onIncrement,
              child: Center(
                child: Icon(
                  Icons.add,
                  color: Colors.black,
                  size: isDesktop ? 16 : (isTablet ? 14 : 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton([bool isDesktop = false, bool isTablet = false]) {
    return GestureDetector(
      onTap: widget.isLocked ? null : widget.onAddToCart,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.isLocked
              ? AppColors.textTertiaryDark
              : AppColors.primary,
          borderRadius: BorderRadius.circular(
            isDesktop ? 16 : (isTablet ? 14 : 12),
          ),
          boxShadow: widget.isLocked
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isLocked ? Icons.lock : Icons.add,
                color: widget.isLocked
                    ? AppColors.textSecondaryDark
                    : Colors.black,
                size: isDesktop ? 14 : (isTablet ? 12 : 10),
              ),
              SizedBox(width: isDesktop ? 6 : 4),
              Text(
                widget.isLocked ? 'Locked' : 'Add',
                style: TextStyle(
                  color: widget.isLocked
                      ? AppColors.textSecondaryDark
                      : Colors.black,
                  fontSize: isDesktop ? 11 : (isTablet ? 10 : 9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

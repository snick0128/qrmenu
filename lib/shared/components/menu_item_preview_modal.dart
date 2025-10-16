import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/menu_item_model.dart';
import '../utils/app_theme.dart';

class MenuItemPreviewModal extends StatefulWidget {
  final MenuItemModel item;
  final VoidCallback onAddToCart;
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final bool isLocked;

  const MenuItemPreviewModal({
    super.key,
    required this.item,
    required this.onAddToCart,
    this.quantity = 0,
    this.onIncrement,
    this.onDecrement,
    this.isLocked = false,
  });

  @override
  State<MenuItemPreviewModal> createState() => _MenuItemPreviewModalState();
}

class _MenuItemPreviewModalState extends State<MenuItemPreviewModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                  maxHeight: 600,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close button
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Image Section
                    Container(
                      height: 200,
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            // Image
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: widget.item.imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: widget.item.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primary.withOpacity(
                                                0.3,
                                              ),
                                              AppColors.secondary.withOpacity(
                                                0.3,
                                              ),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.primary,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          _buildPlaceholder(),
                                    )
                                  : _buildPlaceholder(),
                            ),

                            // Gradient overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.2),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),

                            // Indicators
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Row(
                                children: [
                                  // Veg/Non-veg indicator
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.circle,
                                      color: widget.item.isVeg
                                          ? AppColors.veg
                                          : AppColors.nonVeg,
                                      size: 12,
                                    ),
                                  ),

                                  if (widget.item.isSpicy) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.spicy,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.local_fire_department,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Popular badge
                            if (widget.item.isPopular)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'POPULAR',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Content Section
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and Price
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.item.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: AppColors.textPrimaryDark,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 12),
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
                                    '₹${widget.item.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Description
                            if (widget.item.description.isNotEmpty)
                              Text(
                                widget.item.description,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondaryDark,
                                      height: 1.5,
                                    ),
                              ),

                            const SizedBox(height: 16),

                            // Rating and prep time
                            Row(
                              children: [
                                if (widget.item.rating > 0) ...[
                                  Icon(
                                    Icons.star,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.item.rating}',
                                    style: TextStyle(
                                      color: AppColors.textPrimaryDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${widget.item.reviewCount})',
                                    style: TextStyle(
                                      color: AppColors.textSecondaryDark,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                                Icon(
                                  Icons.access_time,
                                  color: AppColors.textSecondaryDark,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.item.preparationTime,
                                  style: TextStyle(
                                    color: AppColors.textSecondaryDark,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // Action Button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        child: widget.quantity > 0
                            ? _buildQuantityControls()
                            : _buildAddToCartButton(),
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

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.3),
            AppColors.secondary.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.restaurant_menu, color: AppColors.primary, size: 48),
      ),
    );
  }

  Widget _buildQuantityControls() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Decrement button
          Expanded(
            child: GestureDetector(
              onTap: widget.onDecrement,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.remove, color: Colors.black, size: 24),
                ),
              ),
            ),
          ),

          // Quantity display
          Container(
            width: 80,
            child: Center(
              child: Text(
                '${widget.quantity}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Increment button
          Expanded(
            child: GestureDetector(
              onTap: widget.onIncrement,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.add, color: Colors.black, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return GestureDetector(
      onTap: widget.isLocked ? null : widget.onAddToCart,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: widget.isLocked
              ? AppColors.textTertiaryDark
              : AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: widget.isLocked
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isLocked ? Icons.lock : Icons.add_shopping_cart,
                color: widget.isLocked
                    ? AppColors.textSecondaryDark
                    : Colors.black,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                widget.isLocked ? 'Locked' : 'Add to Cart',
                style: TextStyle(
                  color: widget.isLocked
                      ? AppColors.textSecondaryDark
                      : Colors.black,
                  fontSize: 18,
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

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
  final int quantity; // Current quantity in cart
  final VoidCallback? onIncrement; // Callback for increment
  final VoidCallback? onDecrement; // Callback for decrement

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
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    border: Border.all(
                      color: AppColors.surfaceVariantDark.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image section with overlay
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            // Image
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.surfaceVariantDark,
                                    AppColors.surfaceVariantDark.withOpacity(
                                      0.7,
                                    ),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child:
                                  widget.item.imageUrl != null &&
                                      widget.item.imageUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: widget.item.imageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: AppColors.surfaceVariantDark,
                                        child: Center(
                                          child: Icon(
                                            Icons.restaurant_menu,
                                            color: AppColors.textTertiaryDark,
                                            size: 32,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            color: AppColors.surfaceVariantDark,
                                            child: Center(
                                              child: Icon(
                                                Icons.restaurant_menu,
                                                color:
                                                    AppColors.textTertiaryDark,
                                                size: 32,
                                              ),
                                            ),
                                          ),
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.restaurant_menu,
                                        color: AppColors.textTertiaryDark,
                                        size: 32,
                                      ),
                                    ),
                            ),

                            // Gradient overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.3),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),

                            // Veg/Non-veg indicator
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
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
                                  size: 8,
                                ),
                              ),
                            ),

                            // Spicy indicator
                            if (widget.item.isSpicy)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.spicy.withOpacity(0.9),
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
                                    Icons.local_fire_department,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Content section
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Name and price
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.item.name,
                                      style: TextStyle(
                                        color: AppColors.textPrimaryDark,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '₹${widget.item.price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // Description
                              if (widget.item.description != null &&
                                  widget.item.description!.isNotEmpty)
                                Flexible(
                                  child: Text(
                                    widget.item.description!,
                                    style: TextStyle(
                                      color: AppColors.textSecondaryDark,
                                      fontSize: 11,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                              const SizedBox(height: 8),

                              // Add to cart button or quantity controls
                              if (widget.quantity > 0)
                                // Quantity controls when item is in cart
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Decrement button
                                      GestureDetector(
                                        onTap: widget.onDecrement,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.remove,
                                            color: Colors.black,
                                            size: 16,
                                          ),
                                        ),
                                      ),

                                      // Quantity display
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            '${widget.quantity}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Increment button
                                      GestureDetector(
                                        onTap: widget.onIncrement,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.black,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                // Add to cart button when item not in cart
                                SizedBox(
                                  width: double.infinity,
                                  child: GestureDetector(
                                    onTapDown: _handleTapDown,
                                    onTapUp: _handleTapUp,
                                    onTapCancel: _handleTapCancel,
                                    onTap: widget.isLocked
                                        ? null
                                        : widget.onAddToCart,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: widget.isLocked
                                            ? AppColors.textTertiaryDark
                                            : AppColors.primary,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: widget.isLocked
                                            ? null
                                            : [
                                                BoxShadow(
                                                  color: AppColors.primary
                                                      .withOpacity(0.3),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            widget.isLocked
                                                ? Icons.lock
                                                : Icons.add_shopping_cart,
                                            color: widget.isLocked
                                                ? AppColors.textSecondaryDark
                                                : Colors.black,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.isLocked ? 'Locked' : 'Add',
                                            style: TextStyle(
                                              color: widget.isLocked
                                                  ? AppColors.textSecondaryDark
                                                  : Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
          ),
        );
      },
    );
  }
}

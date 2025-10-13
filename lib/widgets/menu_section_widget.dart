import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import '../utils/app_theme.dart';
import '../screens/category_view_all_screen.dart';
import 'menu_item_card.dart';

class MenuSectionWidget extends StatelessWidget {
  final String title;
  final List<MenuItemModel> items;
  final Function(MenuItemModel) onAddToCart;
  final Function(String) getItemQuantity;
  final Function(MenuItemModel)? onDecrement;
  final bool showViewAll;

  const MenuSectionWidget({
    super.key,
    required this.title,
    required this.items,
    required this.onAddToCart,
    required this.getItemQuantity,
    this.onDecrement,
    this.showViewAll = true,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showViewAll && items.length > 4)
                GestureDetector(
                  onTap: () => _navigateToViewAll(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.primary,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Items horizontal list
        SizedBox(
          height: 280,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.take(6).length, // Show max 6 items
            itemBuilder: (context, index) {
              final item = items[index];
              final quantity = getItemQuantity(item.id);

              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                child: MenuItemCard(
                  item: item,
                  quantity: quantity,
                  sessionType: 'dine_in', // Default for now
                  onAddToCart: () => onAddToCart(item),
                  onIncrement: () => onAddToCart(item),
                  onDecrement: onDecrement != null ? () => onDecrement!(item) : null,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  void _navigateToViewAll(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryViewAllScreen(
          categoryName: title,
          items: items,
        ),
      ),
    );
  }
}
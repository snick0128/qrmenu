import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/menu_item_model.dart';
import '../widgets/menu_item_card.dart';

class ResponsiveMenuGrid extends StatelessWidget {
  final List<MenuItemModel> items;
  final Function(MenuItemModel) onAddToCart;
  final Function(MenuItemModel) onIncrement;
  final Function(MenuItemModel) onDecrement;
  final Function(String) getItemQuantity;
  final String sessionType;

  const ResponsiveMenuGrid({
    super.key,
    required this.items,
    required this.onAddToCart,
    required this.onIncrement,
    required this.onDecrement,
    required this.getItemQuantity,
    required this.sessionType,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // Calculate responsive grid parameters
        int crossAxisCount;
        double childAspectRatio;
        double mainAxisSpacing;
        double crossAxisSpacing;

        if (screenWidth < 600) {
          // Mobile - 2 columns
          crossAxisCount = 2;
          childAspectRatio = 0.75;
          mainAxisSpacing = 12;
          crossAxisSpacing = 12;
        } else if (screenWidth < 900) {
          // Tablet - 3 columns
          crossAxisCount = 3;
          childAspectRatio = 0.8;
          mainAxisSpacing = 16;
          crossAxisSpacing = 16;
        } else if (screenWidth < 1200) {
          // Small Desktop - 4 columns
          crossAxisCount = 4;
          childAspectRatio = 0.85;
          mainAxisSpacing = 16;
          crossAxisSpacing = 16;
        } else {
          // Large Desktop - 5 columns
          crossAxisCount = 5;
          childAspectRatio = 0.9;
          mainAxisSpacing = 20;
          crossAxisSpacing = 20;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final quantity = getItemQuantity(item.id);

            return MenuItemCard(
              item: item,
              quantity: quantity,
              sessionType: sessionType,
              onAddToCart: () => onAddToCart(item),
              onIncrement: () => onIncrement(item),
              onDecrement: () => onDecrement(item),
            );
          },
        );
      },
    );
  }
}

// Alternative Masonry Grid for varied heights
class ResponsiveMenuMasonryGrid extends StatelessWidget {
  final List<MenuItemModel> items;
  final Function(MenuItemModel) onAddToCart;
  final Function(MenuItemModel) onIncrement;
  final Function(MenuItemModel) onDecrement;
  final Function(String) getItemQuantity;
  final String sessionType;

  const ResponsiveMenuMasonryGrid({
    super.key,
    required this.items,
    required this.onAddToCart,
    required this.onIncrement,
    required this.onDecrement,
    required this.getItemQuantity,
    required this.sessionType,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // Calculate cross axis count based on screen width
        int crossAxisCount;
        double mainAxisSpacing;
        double crossAxisSpacing;

        if (screenWidth < 600) {
          // Mobile - 2 columns
          crossAxisCount = 2;
          mainAxisSpacing = 12;
          crossAxisSpacing = 12;
        } else if (screenWidth < 900) {
          // Tablet - 3 columns
          crossAxisCount = 3;
          mainAxisSpacing = 16;
          crossAxisSpacing = 16;
        } else if (screenWidth < 1200) {
          // Small Desktop - 4 columns
          crossAxisCount = 4;
          mainAxisSpacing = 16;
          crossAxisSpacing = 16;
        } else {
          // Large Desktop - 5 columns
          crossAxisCount = 5;
          mainAxisSpacing = 20;
          crossAxisSpacing = 20;
        }

        return MasonryGridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final quantity = getItemQuantity(item.id);

            return MenuItemCard(
              item: item,
              quantity: quantity,
              sessionType: sessionType,
              onAddToCart: () => onAddToCart(item),
              onIncrement: () => onIncrement(item),
              onDecrement: () => onDecrement(item),
            );
          },
        );
      },
    );
  }
}

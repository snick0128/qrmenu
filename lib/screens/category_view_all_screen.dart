import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item_model.dart';
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/responsive_menu_grid.dart';
import '../utils/app_theme.dart';

class CategoryViewAllScreen extends StatefulWidget {
  final String categoryName;
  final List<MenuItemModel> items;

  const CategoryViewAllScreen({
    super.key,
    required this.categoryName,
    required this.items,
  });

  @override
  State<CategoryViewAllScreen> createState() => _CategoryViewAllScreenState();
}

class _CategoryViewAllScreenState extends State<CategoryViewAllScreen> {
  final ScrollController _scrollController = ScrollController();
  List<MenuItemModel> _displayedItems = [];
  int _currentPage = 0;
  static const int _itemsPerPage = 10;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadInitialItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialItems() {
    final endIndex = (_currentPage + 1) * _itemsPerPage;
    _displayedItems = widget.items.take(endIndex).toList();
  }

  void _loadMoreItems() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _currentPage++;
          final startIndex = _currentPage * _itemsPerPage;
          final endIndex = (_currentPage + 1) * _itemsPerPage;
          
          if (startIndex < widget.items.length) {
            final newItems = widget.items.skip(startIndex).take(_itemsPerPage).toList();
            _displayedItems.addAll(newItems);
          }
          
          _isLoadingMore = false;
        });
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_displayedItems.length < widget.items.length) {
        _loadMoreItems();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: Text(
          widget.categoryName,
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return Column(
            children: [
              // Header with item count
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${widget.items.length} items available',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 14,
                  ),
                ),
              ),

              // Items grid
              Expanded(
                child: ResponsiveMenuGrid(
                  items: _displayedItems,
                  sessionType: cartProvider.sessionType ?? 'dine_in',
                  onAddToCart: (item) => _addToCart(context, item, cartProvider),
                  onIncrement: (item) => _addToCart(context, item, cartProvider),
                  onDecrement: (item) => _decreaseItemQuantity(context, item, cartProvider),
                  getItemQuantity: (id) => cartProvider.getItemQuantity(id),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addToCart(
    BuildContext context,
    MenuItemModel item,
    CartProvider cartProvider,
  ) async {
    try {
      await cartProvider.addItem(item);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} added to cart'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _decreaseItemQuantity(
    BuildContext context,
    MenuItemModel item,
    CartProvider cartProvider,
  ) async {
    try {
      // Find the item index in cart
      final itemIndex = cartProvider.items.indexWhere(
        (cartItem) => cartItem.menuItem.id == item.id,
      );
      
      if (itemIndex != -1) {
        final currentQuantity = cartProvider.items[itemIndex].quantity;
        if (currentQuantity > 1) {
          await cartProvider.updateQuantity(itemIndex, currentQuantity - 1);
        } else {
          await cartProvider.removeItem(itemIndex);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
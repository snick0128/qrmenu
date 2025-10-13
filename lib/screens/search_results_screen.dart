import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item_model.dart';
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/responsive_menu_grid.dart';
import '../utils/app_theme.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;

  const SearchResultsScreen({
    super.key,
    required this.searchQuery,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ScrollController _scrollController = ScrollController();
  List<MenuItemModel> _displayedItems = [];
  List<MenuItemModel> _allSearchResults = [];
  int _currentPage = 0;
  static const int _itemsPerPage = 10;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSearch();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final menuProvider = context.read<MenuProvider>();
    // Use the public search method
    _allSearchResults = menuProvider.searchItems(widget.searchQuery);
    _loadInitialItems();
  }

  void _loadInitialItems() {
    setState(() {
      _currentPage = 0;
      final endIndex = (_currentPage + 1) * _itemsPerPage;
      _displayedItems = _allSearchResults.take(endIndex).toList();
    });
  }

  void _loadMoreItems() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate network delay for smooth UX
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _currentPage++;
          final startIndex = _currentPage * _itemsPerPage;
          final endIndex = (_currentPage + 1) * _itemsPerPage;
          
          if (startIndex < _allSearchResults.length) {
            final newItems = _allSearchResults.skip(startIndex).take(_itemsPerPage).toList();
            _displayedItems.addAll(newItems);
          }
          
          _isLoadingMore = false;
        });
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_displayedItems.length < _allSearchResults.length) {
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Results',
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '\"${widget.searchQuery}\"',
              style: TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 14,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (_allSearchResults.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Results count header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${_allSearchResults.length} items found',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 14,
                  ),
                ),
              ),

              // Items grid with infinite scroll
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textTertiaryDark,
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Back to Menu',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
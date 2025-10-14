import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/cart_provider.dart';
import '../providers/app_language_provider.dart';
import '../utils/app_theme.dart';
import 'menu_screen.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const MenuScreen(),
      const OrderHistoryScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<AppLanguageProvider>();
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textTertiary,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _currentIndex == 0
                        ? Icons.restaurant
                        : Icons.restaurant_outlined,
                    size: 24,
                  ),
                ),
                label: languageProvider.getText('menu'),
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _currentIndex == 1 ? Icons.history : Icons.history_outlined,
                    size: 24,
                  ),
                ),
                label: languageProvider.getText('order_history'),
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  child: cartProvider.itemCount > 0
                      ? badges.Badge(
                          badgeContent: Text(
                            cartProvider.itemCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          badgeStyle: badges.BadgeStyle(
                            badgeColor: AppColors.primary,
                            padding: const EdgeInsets.all(4),
                          ),
                          child: Icon(
                            _currentIndex == 2
                                ? Icons.shopping_cart
                                : Icons.shopping_cart_outlined,
                            size: 24,
                          ),
                        )
                      : Icon(
                          _currentIndex == 2
                              ? Icons.shopping_cart
                              : Icons.shopping_cart_outlined,
                          size: 24,
                        ),
                ),
                label: languageProvider.getText('cart'),
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _currentIndex == 3 ? Icons.person : Icons.person_outline,
                    size: 24,
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

class MockRestaurant {
  final String name;
  final String tableNumber;
  final String phone;

  const MockRestaurant({
    required this.name,
    required this.tableNumber,
    required this.phone,
  });
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isPopular;
  final bool isQuickOrder;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.isPopular = false,
    this.isQuickOrder = false,
  });
}

final mockRestaurant = MockRestaurant(
  name: 'Sample Restaurant',
  tableNumber: 'T123',
  phone: '+1 (555) 123-4567',
);

final mockMenu = [
  MenuItem(
    id: '1',
    name: 'Classic Burger',
    description: 'Beef patty with lettuce, tomato, and cheese',
    price: 12.99,
    category: 'Burgers',
    isPopular: true,
    isQuickOrder: true,
  ),
  // Add more menu items here
];

List<String> getCategories() {
  return mockMenu.map((item) => item.category).toSet().toList();
}

List<MenuItem> getQuickOrderItems() {
  return mockMenu.where((item) => item.isQuickOrder).toList();
}

List<MenuItem> getPopularItems() {
  return mockMenu.where((item) => item.isPopular).toList();
}

List<MenuItem> getItemsByCategory(String category) {
  return mockMenu.where((item) => item.category == category).toList();
}
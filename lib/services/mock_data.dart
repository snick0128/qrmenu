import '../models/menu_item_model.dart';
import '../models/restaurant_model.dart';

// Mock Restaurant Data
const mockRestaurant = RestaurantModel(
  id: 'rest_001',
  name: 'Spice Garden Restaurant',
  address: '123 Main Street, Food District, City',
  phone: '+91 9876543210',
  tableNumber: '7',
  logoUrl: 'https://via.placeholder.com/200x200/FF6B35/FFFFFF?text=SG',
  settings: {
    'currency': 'INR',
    'tax_rate': 0.18,
    'service_charge': 0.10,
  },
);

// Mock Menu Data with Quick Order Items
final List<MenuItemModel> mockMenu = [
  // QUICK ORDER ITEMS - Most Popular
  const MenuItemModel(
    id: 'quick_001',
    name: 'Butter Roti',
    description: 'Soft, warm Indian bread with butter',
    price: 25.0,
    category: 'Breads',
    imageUrl: 'https://via.placeholder.com/300x200/FFB6C1/000000?text=Butter+Roti',
    isVeg: true,
    isPopular: true,
    isQuickOrder: true,
    rating: 4.6,
    reviewCount: 150,
    preparationTime: '5-8 min',
  ),
  
  const MenuItemModel(
    id: 'quick_002',
    name: 'Plain Roti',
    description: 'Traditional Indian flatbread',
    price: 20.0,
    category: 'Breads',
    imageUrl: 'https://via.placeholder.com/300x200/DEB887/000000?text=Plain+Roti',
    isVeg: true,
    isPopular: true,
    isQuickOrder: true,
    rating: 4.4,
    reviewCount: 200,
    preparationTime: '5-8 min',
  ),

  const MenuItemModel(
    id: 'quick_003',
    name: 'Masala Chai',
    description: 'Traditional Indian spiced tea',
    price: 15.0,
    category: 'Beverages',
    imageUrl: 'https://via.placeholder.com/300x200/CD853F/FFFFFF?text=Masala+Chai',
    isVeg: true,
    isPopular: true,
    isQuickOrder: true,
    rating: 4.8,
    reviewCount: 300,
    preparationTime: '3-5 min',
  ),

  const MenuItemModel(
    id: 'quick_004',
    name: 'Papad (2 pcs)',
    description: 'Crispy lentil wafers',
    price: 30.0,
    category: 'Starters',
    imageUrl: 'https://via.placeholder.com/300x200/F0E68C/000000?text=Papad',
    isVeg: true,
    isPopular: true,
    isQuickOrder: true,
    rating: 4.3,
    reviewCount: 120,
    preparationTime: '2-3 min',
  ),

  // STARTERS
  const MenuItemModel(
    id: 'starter_001',
    name: 'Samosa (2 pcs)',
    description: 'Crispy pastry filled with spiced potatoes and peas',
    price: 40.0,
    category: 'Starters',
    imageUrl: 'https://via.placeholder.com/300x200/FFA500/000000?text=Samosa',
    isVeg: true,
    isSpicy: true,
    rating: 4.5,
    reviewCount: 89,
    allergens: ['gluten'],
  ),

  const MenuItemModel(
    id: 'starter_002',
    name: 'Chicken 65',
    description: 'Spicy deep-fried chicken with curry leaves',
    price: 180.0,
    category: 'Starters',
    imageUrl: 'https://via.placeholder.com/300x200/DC143C/FFFFFF?text=Chicken+65',
    isVeg: false,
    isSpicy: true,
    isPopular: true,
    rating: 4.7,
    reviewCount: 156,
    preparationTime: '12-15 min',
  ),

  const MenuItemModel(
    id: 'starter_003',
    name: 'Paneer Tikka',
    description: 'Grilled cottage cheese cubes marinated in spices',
    price: 220.0,
    category: 'Starters',
    imageUrl: 'https://via.placeholder.com/300x200/FF4500/FFFFFF?text=Paneer+Tikka',
    isVeg: true,
    isSpicy: true,
    isPopular: true,
    rating: 4.6,
    reviewCount: 134,
    preparationTime: '15-18 min',
  ),

  // MAIN COURSE
  const MenuItemModel(
    id: 'main_001',
    name: 'Butter Chicken',
    description: 'Creamy tomato-based curry with tender chicken pieces',
    price: 280.0,
    category: 'Main Course',
    imageUrl: 'https://via.placeholder.com/300x200/FF6347/FFFFFF?text=Butter+Chicken',
    isVeg: false,
    isSpicy: false,
    isPopular: true,
    rating: 4.8,
    reviewCount: 245,
    allergens: ['dairy'],
    preparationTime: '20-25 min',
  ),

  const MenuItemModel(
    id: 'main_002',
    name: 'Dal Tadka',
    description: 'Yellow lentils tempered with cumin and garlic',
    price: 160.0,
    category: 'Main Course',
    imageUrl: 'https://via.placeholder.com/300x200/DAA520/000000?text=Dal+Tadka',
    isVeg: true,
    isSpicy: false,
    isPopular: true,
    rating: 4.4,
    reviewCount: 178,
    preparationTime: '15-20 min',
  ),

  const MenuItemModel(
    id: 'main_003',
    name: 'Paneer Makhani',
    description: 'Rich and creamy cottage cheese curry',
    price: 240.0,
    category: 'Main Course',
    imageUrl: 'https://via.placeholder.com/300x200/FF69B4/FFFFFF?text=Paneer+Makhani',
    isVeg: true,
    isSpicy: false,
    rating: 4.5,
    reviewCount: 167,
    allergens: ['dairy'],
    preparationTime: '18-22 min',
  ),

  const MenuItemModel(
    id: 'main_004',
    name: 'Chicken Biryani',
    description: 'Aromatic basmati rice with marinated chicken and spices',
    price: 320.0,
    category: 'Rice & Biryani',
    imageUrl: 'https://via.placeholder.com/300x200/8B4513/FFFFFF?text=Chicken+Biryani',
    isVeg: false,
    isSpicy: true,
    isPopular: true,
    rating: 4.9,
    reviewCount: 289,
    preparationTime: '25-30 min',
  ),

  const MenuItemModel(
    id: 'main_005',
    name: 'Veg Biryani',
    description: 'Fragrant rice with mixed vegetables and aromatic spices',
    price: 250.0,
    category: 'Rice & Biryani',
    imageUrl: 'https://via.placeholder.com/300x200/228B22/FFFFFF?text=Veg+Biryani',
    isVeg: true,
    isSpicy: true,
    rating: 4.3,
    reviewCount: 145,
    preparationTime: '20-25 min',
  ),

  // BREADS
  const MenuItemModel(
    id: 'bread_001',
    name: 'Garlic Naan',
    description: 'Soft leavened bread topped with fresh garlic',
    price: 45.0,
    category: 'Breads',
    imageUrl: 'https://via.placeholder.com/300x200/F5DEB3/000000?text=Garlic+Naan',
    isVeg: true,
    rating: 4.5,
    reviewCount: 198,
    allergens: ['gluten', 'dairy'],
    preparationTime: '8-10 min',
  ),

  const MenuItemModel(
    id: 'bread_002',
    name: 'Cheese Naan',
    description: 'Naan stuffed with melted cheese',
    price: 65.0,
    category: 'Breads',
    imageUrl: 'https://via.placeholder.com/300x200/FFD700/000000?text=Cheese+Naan',
    isVeg: true,
    rating: 4.6,
    reviewCount: 156,
    allergens: ['gluten', 'dairy'],
    preparationTime: '10-12 min',
  ),

  // BEVERAGES
  const MenuItemModel(
    id: 'bev_001',
    name: 'Fresh Lime Soda',
    description: 'Refreshing lime drink with soda water',
    price: 35.0,
    category: 'Beverages',
    imageUrl: 'https://via.placeholder.com/300x200/32CD32/FFFFFF?text=Lime+Soda',
    isVeg: true,
    rating: 4.2,
    reviewCount: 87,
    preparationTime: '2-3 min',
  ),

  const MenuItemModel(
    id: 'bev_002',
    name: 'Mango Lassi',
    description: 'Creamy yogurt drink blended with fresh mango',
    price: 55.0,
    category: 'Beverages',
    imageUrl: 'https://via.placeholder.com/300x200/FFD700/000000?text=Mango+Lassi',
    isVeg: true,
    rating: 4.7,
    reviewCount: 123,
    allergens: ['dairy'],
    preparationTime: '3-5 min',
  ),

  const MenuItemModel(
    id: 'bev_003',
    name: 'Filter Coffee',
    description: 'South Indian style filtered coffee',
    price: 25.0,
    category: 'Beverages',
    imageUrl: 'https://via.placeholder.com/300x200/8B4513/FFFFFF?text=Filter+Coffee',
    isVeg: true,
    rating: 4.4,
    reviewCount: 145,
    allergens: ['dairy'],
    preparationTime: '4-6 min',
  ),

  // DESSERTS
  const MenuItemModel(
    id: 'dessert_001',
    name: 'Gulab Jamun (2 pcs)',
    description: 'Soft milk dumplings in sugar syrup',
    price: 60.0,
    category: 'Desserts',
    imageUrl: 'https://via.placeholder.com/300x200/8B0000/FFFFFF?text=Gulab+Jamun',
    isVeg: true,
    rating: 4.5,
    reviewCount: 89,
    allergens: ['dairy'],
    preparationTime: '5-7 min',
  ),

  const MenuItemModel(
    id: 'dessert_002',
    name: 'Ice Cream (Vanilla)',
    description: 'Premium vanilla ice cream scoop',
    price: 45.0,
    category: 'Desserts',
    imageUrl: 'https://via.placeholder.com/300x200/FFF8DC/000000?text=Vanilla+Ice+Cream',
    isVeg: true,
    rating: 4.3,
    reviewCount: 67,
    allergens: ['dairy'],
    preparationTime: '1-2 min',
  ),

  // SNACKS
  const MenuItemModel(
    id: 'snack_001',
    name: 'Aloo Paratha',
    description: 'Stuffed flatbread with spiced potato filling',
    price: 80.0,
    category: 'Breads',
    imageUrl: 'https://via.placeholder.com/300x200/D2691E/FFFFFF?text=Aloo+Paratha',
    isVeg: true,
    isSpicy: true,
    isPopular: true,
    rating: 4.4,
    reviewCount: 134,
    allergens: ['gluten'],
    preparationTime: '12-15 min',
  ),

  const MenuItemModel(
    id: 'snack_002',
    name: 'Chole Bhature',
    description: 'Spicy chickpea curry with fluffy fried bread',
    price: 140.0,
    category: 'Main Course',
    imageUrl: 'https://via.placeholder.com/300x200/FF4500/FFFFFF?text=Chole+Bhature',
    isVeg: true,
    isSpicy: true,
    isPopular: true,
    rating: 4.6,
    reviewCount: 189,
    allergens: ['gluten'],
    preparationTime: '15-20 min',
  ),
];

// Quick order items for easy access
List<MenuItemModel> getQuickOrderItems() {
  return mockMenu.where((item) => item.isQuickOrder).toList();
}

// Get items by category
List<MenuItemModel> getItemsByCategory(String category) {
  return mockMenu.where((item) => item.category == category).toList();
}

// Get popular items
List<MenuItemModel> getPopularItems() {
  return mockMenu.where((item) => item.isPopular).toList();
}

// Get all categories
List<String> getCategories() {
  final categories = <String>{};
  for (final item in mockMenu) {
    categories.add(item.category);
  }
  return categories.toList()..sort();
}

// Search items
List<MenuItemModel> searchItems(String query) {
  if (query.isEmpty) return mockMenu;
  
  final lowerQuery = query.toLowerCase();
  return mockMenu.where((item) {
    return item.name.toLowerCase().contains(lowerQuery) ||
           item.description.toLowerCase().contains(lowerQuery) ||
           item.category.toLowerCase().contains(lowerQuery);
  }).toList();
}

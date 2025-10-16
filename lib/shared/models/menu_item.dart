class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isVeg;
  final String imageUrl;
  final String category;
  final bool isAvailable;
  final bool isPopular;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isVeg,
    required this.imageUrl,
    required this.category,
    this.isAvailable = true,
    this.isPopular = false,
  });
}
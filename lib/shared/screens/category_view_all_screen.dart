import 'package:flutter/material.dart';
import '../models/menu_item.dart';

class CategoryViewAllScreen extends StatelessWidget {
  final String categoryName;
  final List<MenuItem> items;

  const CategoryViewAllScreen({
    Key? key,
    required this.categoryName,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement category view all screen
    return Container();
  }
}
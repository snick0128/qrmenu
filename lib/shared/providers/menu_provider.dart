import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';

class MenuProvider with ChangeNotifier {
  String _searchQuery = '';
  List<MenuItem> _searchResults = [];

  String get searchQuery => _searchQuery;
  List<MenuItem> get searchResults => _searchResults;

  void setSearchQuery(String query) {
    _searchQuery = query;
    // Implement search logic here
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }
}
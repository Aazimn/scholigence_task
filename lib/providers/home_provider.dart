import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../models/category.dart';
import '../services/db_service.dart';

class HomeProvider extends ChangeNotifier {
  int _currentIndex = 0;
  String _searchQuery = '';
  List<Category> _searchResults = [];
  bool _isSearching = false;

  int get currentIndex => _currentIndex;
  String get searchQuery => _searchQuery;
  List<Category> get searchResults => _searchResults;
  bool get isSearching => _isSearching;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _searchQuery = query.trim();
    if (_searchQuery.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await DbService.searchCategories(_searchQuery);
    } catch (_) {
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  Future<List<Category>> getCategoryPath(int id) async {
    return DbService.getCategoryPath(id);
  }
}

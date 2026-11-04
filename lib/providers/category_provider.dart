import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../models/category.dart';
import '../services/db_service.dart';

class CategoryProvider extends ChangeNotifier {
  final int? parentId;
  int _currentPage = 1;
  final int _pageSize = 10;
  List<Category> _categories = [];
  int _totalCount = 0;
  bool _isLoading = false;
  String? _error;

  CategoryProvider({this.parentId}) {
    loadCategories();
  }

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalCount => _totalCount;
  int get totalPages => (_totalCount / _pageSize).ceil();
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _totalCount = await DbService.getChildrenCount(parentId);
      final maxPages = (_totalCount / _pageSize).ceil();
      if (_currentPage > maxPages && maxPages > 0) {
        _currentPage = maxPages;
      }
      _categories = await DbService.getChildrenPaged(
        parentId,
        _currentPage,
        _pageSize,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      loadCategories();
    }
  }

  void prevPage() {
    if (_currentPage > 1) {
      _currentPage--;
      loadCategories();
    }
  }

  void setPage(int page) {
    if (page >= 1 && page <= totalPages && page != _currentPage) {
      _currentPage = page;
      loadCategories();
    }
  }

  Future<bool> checkExists(String name, {int? excludeId}) async {
    return DbService.categoryExists(
      name,
      parentId: parentId,
      excludeId: excludeId,
    );
  }

  Future<bool> addCategory(String name) async {
    final result = await DbService.addCategory(name, parentId: parentId);
    if (result != -1) {
      await loadCategories();
      return true;
    }
    return false;
  }

  Future<bool> updateCategory(int id, String newName) async {
    final result = await DbService.updateCategory(
      id,
      newName,
      parentId: parentId,
    );
    if (result != -1) {
      await loadCategories();
      return true;
    }
    return false;
  }

  Future<void> deleteCategory(int id) async {
    await DbService.deleteCategory(id);
    await loadCategories();
  }
}

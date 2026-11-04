import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _user;
  bool _loading = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> login(String username, String email) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _api.login(username, email);
      if (result != null) {
        _user = result;
      } else {
        _error = 'Invalid username or email';
      }
    } catch (e) {
      _error = 'Something went wrong';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}


import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://jsonplaceholder.typicode.com';

 
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>?> login(
    String username,
    String email,
  ) async {
    try {
      final users = await getUsers();

      final user = users.firstWhere(
        (user) =>
            user['username'].toString().toLowerCase() ==
                username.toLowerCase() &&
            user['email'].toString().toLowerCase() ==
                email.toLowerCase(),
        orElse: () => null,
      );

      if (user != null) {
        return Map<String, dynamic>.from(user);
      }

      return null;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
}

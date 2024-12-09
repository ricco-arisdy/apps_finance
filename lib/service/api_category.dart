import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryService {
  final String baseUrl = "http://192.168.100.6/ap_finance/categories.php";

  // Get all categories or by name
  Future<List<dynamic>> getCategories({String? name}) async {
    try {
      final uri = name != null
          ? Uri.parse(
              '$baseUrl?name=$name') // Menggunakan query string untuk name
          : Uri.parse(baseUrl);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data; // Jika hasilnya array
        } else if (data is Map && data.containsKey('message')) {
          return []; // Jika tidak ditemukan
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to fetch categories: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  // Add new category
  Future<void> addCategory(String name) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'name': name},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('error')) {
          throw Exception('Error adding category: ${data['error']}');
        }
      } else {
        throw Exception(
            'Failed to add category: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error adding category: $e');
    }
  }
}

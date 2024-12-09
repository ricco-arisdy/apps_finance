import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String cashflowUrl = "http://192.168.100.6/ap_finance/cashflow.php";
  final String categoryUrl = "http://192.168.100.6/ap_finance/categories.php";

  // Fungsi untuk mendapatkan data cashflows berdasarkan rentang tanggal
  Future<List<dynamic>> getCashflows(String startDate, String endDate,
      {String? jenis}) async {
    try {
      String url = '$cashflowUrl?start_date=$startDate&end_date=$endDate';
      if (jenis != null) {
        url += '&jenis=$jenis';
      }

      print('Fetching data from URL: $url'); // Debug log untuk URL

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Mapping data
        return data.map((item) {
          return {
            'id': item['id'].toString(),
            'nominal': item['nominal'].toString(),
            'tanggal': item['tanggal'].toString(),
            'jenis': item['jenis'] ?? '',
            'deskripsi': item['deskripsi'] ?? '',
            'category_id': item['category_id']?.toString() ?? '',
            'category_name': item['category_name'] ?? '',
          };
        }).toList();
      } else {
        throw Exception('Failed to load cashflows: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  // Fungsi untuk mendapatkan daftar kategori
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(Uri.parse(categoryUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Pastikan data kategori dipetakan dengan benar
        return data.map((item) {
          return {
            'id': item['id'].toString(),
            'name': item['name'] ?? '',
          };
        }).toList();
      } else {
        throw Exception('Failed to load categories: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  // Fungsi untuk menambahkan data cashflow
  Future<void> addCashflow(Map<String, String> data) async {
    try {
      print('Sending data: $data');
      final response = await http.post(
        Uri.parse(cashflowUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: data,
      );

      if (response.statusCode != 200) {
        print(
            'Response body: ${response.body}'); // Tambahkan log untuk debugging
        throw Exception('Failed to add cashflow: ${response.body}');
      }
    } catch (e) {
      print('Error: $e'); // Tambahkan log error
      throw Exception('Error adding data: $e');
    }
  }
}

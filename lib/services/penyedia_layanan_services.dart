import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:laundry_app/utils/constants.dart';
import 'package:laundry_app/models/penyedia_layanan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PenyediaLayananService {
  /// Mendapatkan daftar layanan dengan paginasi
  static Future<Map<String, dynamic>> getPenyediaLayanan({
    int page = 1,
    int limit = 10,
    int? userId, // Tambahkan parameter userId
  }) async {
    try {
      // Build URL with user_id if provided
      String urlString = "$baseUrl$urlPenyediaLayanan/?page=$page&limit=$limit";
      if (userId != null) {
        urlString += "&user_id=$userId";
      }

      final url = Uri.parse(urlString);
      final response = await http.get(url, headers: globalHeaders);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<PenyediaLayanan> penyediaLayanan = (data['data'] as List)
            .map((item) => PenyediaLayanan.fromJson(item))
            .toList();

        return {
          'meta': data['meta'],
          'pagination': data['pagination'],
          'data': penyediaLayanan,
        };
      } else {
        throw Exception('Failed to load layanan.');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Mendapatkan detail layanan berdasarkan ID
  static Future<PenyediaLayanan?> getDetailLayanan(int id) async {
    try {
      final url = Uri.parse("$baseUrl$urlPenyediaLayanan/$id");
      final response = await http.get(url, headers: globalHeaders);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] == null) {
          throw Exception('Data tidak ditemukan.');
        }
        return PenyediaLayanan.fromJson(data['data']);
      } else {
        throw Exception(
            'Failed to load detail layanan. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  static Future<void> createLayananProfile(
    String namaToko,
    String deskripsi,
    String alamat,
    String lat,
    String long,
    String userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = Uri.parse("$baseUrl$urlPenyediaLayanan/");
    final payload = {
      'nama_toko': namaToko,
      'deskripsi': deskripsi,
      'alamat': alamat,
      'lat': lat,
      'long': long,
      'user_id': userId,
    };
    final response = await http.post(url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'aapplication/x-www-form-urlencoded',
        },
        body: jsonEncode(payload));

    if (response.statusCode == 200) {
      // Successful response
      print('Profile created successfully');
    } else {
      // Failed response, log the error
      print('Failed to create profile: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to create profile');
    }
  }

  static Future<void> updateLayananProfile(
      String id, Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = Uri.parse("$baseUrl$urlPenyediaLayanan/$id");

    final response = await http.put(url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload));

    if (response.statusCode == 200) {
      // Successful response
      print('Profile updated successfully');
    } else {
      // Failed response, log the error
      print('Failed to update profile: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to update profile');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:laundry_app/utils/constants.dart';
import 'package:laundry_app/models/penyedia_layanan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PenyediaLayananService {
  /// Mendapatkan daftar layanan dengan paginasi
  static Future<Map<String, dynamic>> getPenyediaLayanan({
    required int page,
    required int limit,
    String? search,
    String? userId,
    double? userLat,
    double? userLng,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (userId != null) 'user_id': userId,
        if (userLat != null) 'user_lat': userLat.toString(),
        if (userLng != null) 'user_lng': userLng.toString(),
      };

      final Uri url = Uri.parse('$baseUrl/penyedia_layanan')
          .replace(queryParameters: queryParams);

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to fetch layanan. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

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

  static Future<PenyediaLayanan> getPenyediaLayananProfile(int id) async {
    try {
      final url = Uri.parse("$baseUrl$urlPenyediaLayananProfile/$id");
      final response = await http.get(url, headers: globalHeaders);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] == null) {
          throw Exception('Data tidak ditemukan.');
        }
        return PenyediaLayanan.fromJson(data['data']);
      } else {
        throw Exception(
            'Failed to load profile penyedia layanan. Status code: ${response.statusCode}');
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
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: payload, // Send as form data
    );

    if (response.statusCode != 200) {
      print('Failed to create profile: ${response.body}');
      throw Exception('Failed to create profile');
    }
  }

  static Future<void> updateLayananProfile(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = Uri.parse("$baseUrl$urlPenyediaLayanan/$id");

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: payload, // Send as form data
    );

    if (response.statusCode != 200) {
      print('Failed to update profile: ${response.body}');
      throw Exception('Failed to update profile');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:laundry_app/models/pesanan.dart';
import 'package:laundry_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PesananServices {
  Future<List<Pesanan>> getPesanan({
    required int page,
    String? search,
    int? layananId,
  }) async {
    final queryParameters = {
      'page': page.toString(),
      'limit': '10',
      'search': search ?? '',
      'layanan_id': layananId?.toString() ?? '',
    };

    print('Query Parameters: $queryParameters');

    final uri = Uri.parse("$baseUrl/pesanan/")
        .replace(queryParameters: queryParameters);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['meta']['code'] == 200) {
        final data = jsonResponse['data'] as List<dynamic>;
        return data.map((item) => Pesanan.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to fetch Pesanan list: ${jsonResponse['meta']['message']}');
      }
    } else {
      throw Exception(
          'Failed to fetch Pesanan list. HTTP Status: ${response.statusCode}');
    }
  }

  Future<Pesanan> getPesananById(int id) async {
    final url = Uri.parse("$baseUrl/pesanan/$id");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['meta']['code'] == 200) {
        final data = jsonResponse['data'];
        return Pesanan.fromJson(data);
      } else {
        throw Exception(
            'Failed to fetch Pesanan details: ${jsonResponse['meta']['message']}');
      }
    } else {
      throw Exception(
          'Failed to fetch Pesanan details. HTTP Status: ${response.statusCode}');
    }
  }

  // Create Pesanan

  Future<Pesanan> createPesanan(
    String pNama,
    String pNoHp,
    String pDate,
    String pQuisioner,
    int pStatus,
    String pAlamat,
    int layananId,
  ) async {
    final url = Uri.parse("$baseUrl/pesanan/");
    final headers = {
      'Content-Type': 'multipart/form-data',
    };

    pStatus = 1;
    final request = http.MultipartRequest('POST', url)
      ..fields.addAll({
        'p_nama': pNama,
        'p_no_hp': pNoHp,
        'p_date': DateTime.parse(pDate).toUtc().toIso8601String(),
        'p_quisioner': pQuisioner,
        'p_status': pStatus.toString(),
        'p_alamat': pAlamat,
        'layanan_id': layananId.toString(),
      })
      ..headers.addAll(headers);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      if (jsonResponse['meta']['code'] == 200) {
        final data = jsonResponse['data'];
        return Pesanan.fromJson(data);
      } else {
        throw Exception(
            'Failed to create Pesanan: ${jsonResponse['meta']['message']}');
      }
    } else {
      throw Exception(
          'Failed to create Pesanan. HTTP Status: ${response.statusCode}');
    }
  }

  // Update Pesanan
  Future<Pesanan> updatePesanan(
    int id,
    String pNama,
    String pNoHp,
    String pDate,
    String pQuisioner,
    int pStatus,
    String pAlamat,
  ) async {
    final url = Uri.parse("$baseUrl/pesanan/$id");
    final headers = {
      'Content-Type': 'multipart/form-data',
    };

    final request = http.MultipartRequest('PUT', url)
      ..fields.addAll({
        'p_nama': pNama,
        'p_no_hp': pNoHp,
        'p_date': pDate,
        'p_quisioner': pQuisioner,
        'p_status': pStatus.toString(),
        'p_alamat': pAlamat,
      })
      ..headers.addAll(headers);

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Pesanan.fromJson(data);
    } else {
      throw Exception('Failed to update Pesanan');
    }
  }

  // Delete Pesanan
  Future<void> deletePesanan(int id) async {
    final url = Uri.parse("$baseUrl/pesanan/$id");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete Pesanan');
    }
  }
}

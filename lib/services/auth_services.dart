import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laundry_app/utils/constants.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl$urlAuthLogin"),
        headers: globalHeaders,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meta']['status'] == 'Success') {
          final accessToken = data['data']['access_token'];
          final userId = data['data']['user']['id']; // Retrieve user_id
          print('User ID: $userId');
          // Check if user_id is null
          if (userId == null) {
            throw Exception('User ID is missing in the response');
          }

          globalHeaders['Authorization'] =
              'Bearer $accessToken'; // Add token to global headers

          // Save access token and user ID to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', accessToken);
          await prefs.setInt(
              'user_id', userId); // Save user_id to shared preferences
          var user_id = prefs.getInt('user_id');
          print('User ID saved to shared preferences: $user_id');
          return data;
        } else {
          throw Exception(data['meta']['message']);
        }
      } else {
        throw Exception('Failed to login. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred during login: $e');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<bool> checkToken() async {
    final url = Uri.parse("$baseUrl$urlAuthCheckToken");
    final token = await getToken();

    if (token == null) {
      return false; // No token found, not authenticated
    }

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['meta']['status'] == 'Success';
      } else {
        return false; // Invalid token
      }
    } catch (e) {
      return false; // Handle network errors or exceptions
    }
  }

  Future<void> refreshToken() async {
    final url = Uri.parse("$baseUrl$urlAuthRefreshToken");
    final token = await getToken();

    if (token == null) {
      throw Exception('No token found. Please login first.');
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer $token",
        },
        body: {},
      );

      print('Refresh Token Response Status: ${response.statusCode}');
      print('Refresh Token Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meta']['status'] == 'Success') {
          final newToken = data['data']['access_token'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', newToken);
        } else {
          throw Exception(data['meta']['message']);
        }
      } else {
        throw Exception(
            'Failed to refresh token. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while refreshing token: $e');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email,
      String password, String noHp, int roleId, String alamat) async {
    final url = Uri.parse("$baseUrl$urlAuthRegister");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          'name': name,
          'email': email,
          'password': password,
          'no_hp': noHp,
          'role_id': roleId.toString(),
          'alamat': alamat,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meta']['status'] == 'Success') {
          return data;
        } else {
          throw Exception(data['meta']['message']);
        }
      } else {
        throw Exception(
            'Failed to register. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred during registration: $e');
    }
  }

  Future<void> logout(BuildContext context) async {
    final url = Uri.parse("$baseUrl$urlAuthLogout");
    final token = await getToken();

    if (token == null) {
      throw Exception('No token found. Please login first.');
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meta']['status'] == 'Success') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('accessToken');
          globalHeaders.remove('Authorization');

          // Navigasi ke layar login setelah logout
          Navigator.pushReplacementNamed(context, '/');
        } else {
          throw Exception(data['meta']['message']);
        }
      } else {
        throw Exception(
            'Failed to logout. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred during logout: $e');
    }
  }
}

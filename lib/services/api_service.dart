import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      print('REGISTER STATUS: ${response.statusCode}');
      print('REGISTER BODY: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Registration failed'};
      }
    } catch (e) {
      print('REGISTER ERROR: $e');
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': password},
      );
      print('LOGIN STATUS: ${response.statusCode}');
      print('LOGIN BODY: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await saveToken(data['access_token']);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Login failed'};
      }
    } catch (e) {
      print('LOGIN ERROR: $e');
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('PROFILE STATUS: ${response.statusCode}');
      print('PROFILE BODY: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed to get profile'};
      }
    } catch (e) {
      print('PROFILE ERROR: $e');
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> submitGadget({
    required String itemName,
    required String damageDescription,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/gadgets/submit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'item_name': itemName,
          'damage_description': damageDescription,
        }),
      );
      print('GADGET STATUS: ${response.statusCode}');
      print('GADGET BODY: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed to submit'};
      }
    } catch (e) {
      print('GADGET ERROR: $e');
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }
}
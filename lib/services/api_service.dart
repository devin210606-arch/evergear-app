import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static final ValueNotifier<int> currentWalletBalance = ValueNotifier<int>(0);

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
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed to submit'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  // ─── LISTINGS ────────────────────────────────────────────
  static Future<Map<String, dynamic>> getListings({
    String? category,
    String? search,
  }) async {
    try {
      final token = await getToken();
      String url = '$baseUrl/listings';
      final params = <String>[];
      if (category != null) params.add('category=$category');
      if (search != null && search.isNotEmpty) params.add('search=$search');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed to get listings'};
      }
    } catch (e) {
      print('LISTINGS ERROR: $e');
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> getMyListings() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/listings/mine'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> createListing({
    required String title,
    required int price,
    required String category,
    required String condition,
    required String description,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/listings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'price': price,
          'category': category,
          'condition': condition,
          'description': description,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed to create listing'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> updateListing({
    required int listingId,
    required String title,
    required int price,
    required String category,
    required String condition,
    required String description,
  }) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/listings/$listingId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'price': price,
          'category': category,
          'condition': condition,
          'description': description,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed to update'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> deleteListing(int listingId) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/listings/$listingId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['detail'] ?? 'Failed to delete'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  // ─── ORDERS ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> createOrder({
    required int listingId,
    required String paymentMethod,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'listing_id': listingId,
          'payment_method': paymentMethod,
        }),
      );
      print('ORDER STATUS: ${response.statusCode}');
      print('ORDER BODY: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed to create order'};
      }
    } catch (e) {
      print('ORDER ERROR: $e');
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> getMyOrders() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> getMySellingOrders() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/selling'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> confirmReceived(int orderId) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/confirm'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  // UPDATE PROFILE
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone ?? '',
        }),
      );
      print('UPDATE PROFILE STATUS: ${response.statusCode}');
      print('UPDATE PROFILE BODY: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed to update profile'};
      }
    } catch (e) {
      print('UPDATE PROFILE ERROR: $e');
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  // CHANGE PASSWORD
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/users/me/password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );
      print('CHANGE PASSWORD STATUS: ${response.statusCode}');
      print('CHANGE PASSWORD BODY: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed to change password'};
      }
    } catch (e) {
      print('CHANGE PASSWORD ERROR: $e');
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static String formatPrice(dynamic price) {
    final number = int.tryParse(price.toString()) ?? 0;
    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp. $formatted';
  }

  // WALLET
  static Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/wallet/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        currentWalletBalance.value = data['balance'] ?? 0;
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> topUpWallet(int amount) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/wallet/topup'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'amount': amount}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> withdrawWallet({
    required int amount,
    required String bankAccount,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/wallet/withdraw'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'amount': amount, 'bank_account': bankAccount}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> getTransactions() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/wallet/transactions'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  // ECO STATS
  static Future<Map<String, dynamic>> getEcoStats() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/users/me/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  // ─── CHAT (NEW) ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> getMyChats() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/chats/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> startConversation(int listingId) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/chats/start/$listingId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> getChatMessages(int conversationId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/chats/$conversationId/messages'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

  static Future<Map<String, dynamic>> sendMessage({
    required int conversationId,
    required String text,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/chats/$conversationId/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'text': text}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Failed'};
      }
    } catch (e) {
      print('SEND MESSAGE ERROR: $e');
      return {'success': false, 'message': 'Cannot connect to server'};
    }
  }

}
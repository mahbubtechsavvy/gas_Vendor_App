import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../config/app_config.dart';

class ShopStatusService {
  static const String baseUrl = '${AppConfig.apiBaseUrl}/vendor';

  /// Get current shop status
  static Future<bool> getShopStatus(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shop_status.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['is_open'] ?? false;
        }
      }
      throw Exception('Failed to get shop status');
    } catch (e) {
      debugPrint('Error getting shop status: $e');
      rethrow;
    }
  }

  /// Update shop status
  static Future<bool> updateShopStatus(String token, bool isOpen) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/shop_status.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'is_open': isOpen}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      throw Exception('Failed to update shop status');
    } catch (e) {
      debugPrint('Error updating shop status: $e');
      rethrow;
    }
  }
}

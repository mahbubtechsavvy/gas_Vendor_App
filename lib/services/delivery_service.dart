import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class DeliveryService {
  static const String _baseUrl = AppConfig.apiBaseUrl;

  /// Get delivery hours from API
  static Future<List<Map<String, dynamic>>> getDeliveryHours() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.get(
        Uri.parse('$_baseUrl/vendor/delivery_hours.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('DeliveryService GET response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['delivery_hours'] != null) {
          return List<Map<String, dynamic>>.from(data['delivery_hours']);
        }
      }
      return [];
    } catch (e) {
      debugPrint('DeliveryService GET error: $e');
      return [];
    }
  }

  /// Update delivery hours via API
  static Future<bool> updateDeliveryHours(
    List<Map<String, dynamic>> hours,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.put(
        Uri.parse('$_baseUrl/vendor/delivery_hours.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'delivery_hours': hours}),
      );

      debugPrint('DeliveryService PUT response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('DeliveryService PUT error: $e');
      return false;
    }
  }
}

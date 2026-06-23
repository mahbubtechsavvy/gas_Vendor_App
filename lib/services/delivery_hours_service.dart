import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../config/app_config.dart';
import '../models/delivery_hour.dart';

class DeliveryHoursService {
  static const String baseUrl = '${AppConfig.apiBaseUrl}/vendor';

  /// Get delivery hours for all days
  static Future<List<DeliveryHour>> getDeliveryHours(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/delivery_hours.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> hoursData = data['delivery_hours'];
          return hoursData.map((h) => DeliveryHour.fromJson(h)).toList();
        }
      }
      throw Exception('Failed to get delivery hours');
    } catch (e) {
      debugPrint('Error getting delivery hours: $e');
      rethrow;
    }
  }

  /// Update delivery hours
  static Future<bool> updateDeliveryHours(
    String token,
    List<DeliveryHour> hours,
  ) async {
    try {
      final hoursData = hours.map((h) => h.toJson()).toList();

      final response = await http.put(
        Uri.parse('$baseUrl/delivery_hours.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'delivery_hours': hoursData}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      throw Exception('Failed to update delivery hours');
    } catch (e) {
      debugPrint('Error updating delivery hours: $e');
      rethrow;
    }
  }
}

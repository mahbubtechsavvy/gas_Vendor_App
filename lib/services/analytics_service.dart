import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../config/app_config.dart';
import '../models/analytics_data.dart';

class AnalyticsService {
  static const String baseUrl = '${AppConfig.apiBaseUrl}/vendor';

  /// Get analytics data
  static Future<AnalyticsData> getAnalytics(
    String token, {
    int range = 30,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analytics.php?range=$range'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return AnalyticsData.fromJson(data);
        }
      }
      throw Exception('Failed to get analytics');
    } catch (e) {
      debugPrint('Error getting analytics: $e');
      rethrow;
    }
  }
}

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../config/app_config.dart';

class SupportService {
  static const String baseUrl = '${AppConfig.apiBaseUrl}/vendor';

  /// Create support ticket
  static Future<String> createSupportTicket({
    required String token,
    required String ownerName,
    required String contractNumber,
    required String vendorId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit_support_ticket.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'owner_name': ownerName,
          'contract_number': contractNumber,
          'vendor_id': vendorId,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['ticket_number'] ?? '';
        }
      }
      throw Exception('Failed to create support ticket');
    } catch (e) {
      debugPrint('Error creating support ticket: $e');
      rethrow;
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/subscription_plan.dart';
import '../models/vendor_subscription.dart';
import '../config/api_config.dart';

class SubscriptionService {
  /// Fetch active subscription plans from API
  Future<List<SubscriptionPlan>> getPlans() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/subscription/get_plans.php'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['plans'] != null) {
          return (data['plans'] as List)
              .map((json) => SubscriptionPlan.fromJson(json))
              .toList();
        }
      }
      debugPrint('Get plans error: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      debugPrint('Get plans error: $e');
      return [];
    }
  }

  /// Fetch vendor's current subscription info
  Future<VendorSubscription?> getVendorSubscription(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/subscription/get_vendor_subscription.php',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return VendorSubscription.fromJson(data);
        }
      }
      debugPrint(
        'Get vendor subscription error: ${response.statusCode} - ${response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Get vendor subscription error: $e');
      return null;
    }
  }

  /// Validate promo code server-side
  /// Returns a map with discount info or error message
  Future<Map<String, dynamic>> validatePromo({
    required String code,
    required int planId,
    int vendorId = 0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/subscription/validate_promo.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': code,
          'plan_id': planId,
          'vendor_id': vendorId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      debugPrint('Validate promo error: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Submit payment details to backend
  Future<bool> submitPayment({
    required String vendorId,
    required String vendorUniqueId,
    required String ownerName,
    required String contractNumber,
    required String shopName,
    required String bkashNumber,
    required String transactionId,
    required String promoCode,
    required int planId,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/vendor/submit_subscription_payment.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vendor_id': vendorId,
          'vendor_unique_id': vendorUniqueId,
          'owner_name': ownerName,
          'contract_number': contractNumber,
          'shop_name': shopName,
          'bkash_number': bkashNumber,
          'transaction_id': transactionId,
          'promo_code': promoCode,
          'plan_id': planId,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Payment API response: $data');
        return data['success'] == true;
      }
      debugPrint(
        'Payment API Error: ${response.statusCode} - ${response.body}',
      );
      return false;
    } catch (e) {
      debugPrint('Subscription payment error: $e');
      return false;
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

enum AccessLevel { profileOnly, subscriptionOnly, full }

class VendorAccessInfo {
  final String vendorId;
  final int profileCompletion;
  final bool isVerified;
  final String subscriptionStatus;
  final String? subscriptionExpiresAt;
  final bool subscriptionValid;
  final AccessLevel accessLevel;
  final bool isOpen;
  final Map<String, bool> requiredFields;

  VendorAccessInfo({
    required this.vendorId,
    required this.profileCompletion,
    required this.isVerified,
    required this.subscriptionStatus,
    this.subscriptionExpiresAt,
    required this.subscriptionValid,
    required this.accessLevel,
    required this.isOpen,
    required this.requiredFields,
  });

  factory VendorAccessInfo.fromJson(Map<String, dynamic> json) {
    AccessLevel level = AccessLevel.full;
    switch (json['access_level']) {
      case 'profile_only':
        level = AccessLevel.profileOnly;
        break;
      case 'subscription_only':
        level = AccessLevel.subscriptionOnly;
        break;
      default:
        level = AccessLevel.full;
    }

    return VendorAccessInfo(
      vendorId: json['vendor_id'] ?? '',
      profileCompletion: json['profile_completion'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      subscriptionStatus: json['subscription_status'] ?? 'none',
      subscriptionExpiresAt: json['subscription_expiry'],
      subscriptionValid: json['subscription_valid'] ?? false,
      accessLevel: level,
      isOpen: json['is_open'] ?? false,
      requiredFields: Map<String, bool>.from(json['required_fields'] ?? {}),
    );
  }
}

class AccessControlService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// Check vendor access level
  static Future<VendorAccessInfo?> checkAccess() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      if (token.isEmpty) {
        return null;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/vendor/check_access.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('AccessControl response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final accessInfo = VendorAccessInfo.fromJson(data);

          // Cache access info locally
          await prefs.setInt(
            'profile_completion',
            accessInfo.profileCompletion,
          );
          await prefs.setBool('is_verified', accessInfo.isVerified);
          await prefs.setString(
            'subscription_status',
            accessInfo.subscriptionStatus,
          );
          await prefs.setString('access_level', accessInfo.accessLevel.name);
          await prefs.setString('vendor_id', accessInfo.vendorId);

          return accessInfo;
        }
      }
      return null;
    } catch (e) {
      debugPrint('AccessControl error: $e');
      return null;
    }
  }

  /// Get cached access level (for quick checks)
  static Future<AccessLevel> getCachedAccessLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final level = prefs.getString('access_level') ?? 'full';
    switch (level) {
      case 'profileOnly':
      case 'profile_only':
        return AccessLevel.profileOnly;
      case 'subscriptionOnly':
      case 'subscription_only':
        return AccessLevel.subscriptionOnly;
      default:
        return AccessLevel.full;
    }
  }

  /// Get cached vendor ID
  static Future<String> getCachedVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('vendor_id') ?? '';
  }

  /// Get cached verification status
  static Future<bool> isVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_verified') ?? false;
  }

  /// Get cached profile completion
  static Future<int> getProfileCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('profile_completion') ?? 0;
  }
}

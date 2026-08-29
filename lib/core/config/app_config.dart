import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'Gas Lagba Vendor';
  static const String appVersion = '1.0.0';

  // Base API configuration with live production support
  static String get apiBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;

    return 'https://gaslagbaapi.gtgroup.cloud/api/v1';
  }

  // Storage Keys
  static const String keyAuthToken = 'gl_vendor_auth_token';
  static const String keyUserRole = 'gl_vendor_user_role';
  static const String keySelectedBranchId = 'gl_vendor_active_branch_id';
  static const String keyLocale = 'gl_vendor_locale';
  static const String keyFcmToken = 'gl_vendor_fcm_token';

  // Request Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}

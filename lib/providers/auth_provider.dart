import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vendor.dart';
import '../models/vendor_status.dart';
import '../services/auth_service.dart';
import '../services/demo_data.dart';
import '../config/api_config.dart';
// DEV-LOGIN-BACKDOOR — remove with lib/dev/dev_login.dart.
import '../dev/dev_login.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  Vendor? _vendor;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  Vendor? get vendor => _vendor;
  String? get token => _authService.currentToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  // Check login status on app start
  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        _vendor = await _authService.getVendorData();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Register
  Future<bool> register({
    required String name,
    required String fatherName,
    required String village,
    required String houseName,
    required String mobile,
    required String password,
    required String businessName,
    required String businessType,
    String? nid,
    String? email,
    String? shopAddress,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(
        name: name,
        fatherName: fatherName,
        village: village,
        houseName: houseName,
        mobile: mobile,
        password: password,
        businessName: businessName,
        businessType: businessType,
        nid: nid,
        email: email,
        shopAddress: shopAddress,
      );
      final token = _authService.currentToken;
      if (token?.isNotEmpty == true) {
        debugPrint('Vendor registered, token saved.');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login({required String mobile, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Map<String, dynamic> response;

      // Check if demo mode is enabled
      if (ApiConfig.useDemoMode) {
        // Simulate network delay
        await Future.delayed(const Duration(seconds: 1));

        // Check demo credentials
        if (DemoData.isValidDemoCredentials(mobile, password)) {
          response = DemoData.getDemoLoginResponse();
        } else {
          throw Exception(
            'Invalid demo credentials. Use:\\nMobile: ${DemoData.demoPhone}\\nPassword: ${DemoData.demoPassword}',
          );
        }
      } else {
        // Use actual backend API
        response = await _authService.login(mobile: mobile, password: password);
        final loginToken = response['token'] as String?;
        if (loginToken?.isNotEmpty == true) {
          debugPrint('Vendor logged in, token ready.');
        }
      }

      // Extract vendor data from response
      // Response can be: {vendor: {...}, token: "..."} or {data: {...}, token: "..."}
      dynamic vendorData;
      if (response['vendor'] != null) {
        vendorData = response['vendor'];
      } else if (response['data'] != null) {
        vendorData = response['data'];
      } else {
        // Fallback: use response itself if it contains vendor fields
        vendorData = response;
      }

      if (vendorData == null) {
        throw Exception('No vendor data in login response');
      }

      final vendor = Vendor.fromJson(vendorData);

      // Check vendor status
      if (vendor.status != VendorStatus.approved && !ApiConfig.useDemoMode) {
        // In demo mode we allow login even if pending for testing
        // In production, we might want to restrict or show a different screen
        // For now, we'll store the vendor and let the UI handle the redirection
      }

      _vendor = vendor;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// DEV-LOGIN-BACKDOOR — TEMPORARY. Saves a fabricated local session so the UI can be
  /// browsed without a backend. Compiled out of release builds; see lib/dev/dev_login.dart.
  Future<bool> devLogin() async {
    if (!DevLogin.enabled) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final vendor = DevLogin.vendor();
      await _authService.saveVendorData(vendor, DevLogin.token);
      _vendor = vendor;
      _isLoggedIn = true;
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _vendor = null;
      _isLoggedIn = false;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update Profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vendor = await _authService.updateProfile(updates);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update vendor data locally
  Future<void> updateVendorData(Map<String, dynamic> vendorData) async {
    try {
      _vendor = Vendor.fromJson(vendorData);

      // Save updated vendor to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConfig.vendorKey, jsonEncode(vendorData));

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating vendor data: $e');
    }
  }

  // Clear Error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

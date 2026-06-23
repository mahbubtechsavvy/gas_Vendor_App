import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/api_config.dart';
import '../models/vendor.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // Check if user is logged in
  String? get currentToken => _storageService.getString(ApiConfig.tokenKey);

  Future<bool> isLoggedIn() async {
    return _storageService.getBool(ApiConfig.isLoggedInKey) ?? false;
  }

  // Get stored vendor data
  Future<Vendor?> getVendorData() async {
    final vendorJson = _storageService.getObject(ApiConfig.vendorKey);
    if (vendorJson == null) return null;
    return Vendor.fromJson(vendorJson);
  }

  // Save vendor data
  Future<void> saveVendorData(Vendor vendor, String token) async {
    await _storageService.saveObject(ApiConfig.vendorKey, vendor.toJson());
    await _storageService.saveString(ApiConfig.tokenKey, token);
    await _storageService.saveBool(ApiConfig.isLoggedInKey, true);
  }

  // Register vendor — no OTP required
  Future<Map<String, dynamic>> register({
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
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        data: {
          'user_type': 'vendor',
          'phone': mobile,
          'name': name,
          'father_name': fatherName,
          'village': village,
          'house_name': houseName,
          'password': password,
          'shop_name': businessName,
          'business_type': businessType,
          'nid': nid,
          'email': email,
          'address': shopAddress ?? '',
          'shop_address': shopAddress ?? '',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        // Save vendor data and token for auto-login
        final token = responseData['token'] ?? '';
        if (token.isNotEmpty) {
          dynamic vendorData;
          if (responseData['vendor'] != null) {
            vendorData = responseData['vendor'];
          } else if (responseData['data'] != null) {
            vendorData = responseData['data'];
          }

          if (vendorData != null) {
            final vendor = Vendor.fromJson(vendorData);
            await saveVendorData(vendor, token);
          }
        }

        return responseData;
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String mobile,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        data: {'type': 'vendor', 'phone': mobile, 'password': password},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle different response structures
        dynamic vendorData;
        if (responseData['data'] != null) {
          vendorData = responseData['data'];
        } else if (responseData['vendor'] != null) {
          vendorData = responseData['vendor'];
        } else {
          vendorData = responseData;
        }

        if (vendorData == null) {
          throw Exception('Invalid response format: vendor data not found');
        }

        final token = responseData['token'] ?? '';
        final vendor = Vendor.fromJson(vendorData);

        // Save vendor data and token
        await saveVendorData(vendor, token);

        return responseData;
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Clear local data
      await _storageService.remove(ApiConfig.tokenKey);
      await _storageService.remove(ApiConfig.vendorKey);
      await _storageService.saveBool(ApiConfig.isLoggedInKey, false);

      // Try to call logout API (optional, may fail)
      try {
        await _apiService.post(ApiConfig.logout, data: {});
      } catch (e) {
        debugPrint('Logout API call failed (non-critical): $e');
      }
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String mobile) async {
    try {
      final response = await _apiService.post(
        ApiConfig.forgotPassword,
        data: {'phone': mobile, 'type': 'vendor'},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Request failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Update profile
  Future<Vendor> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.post(
        ApiConfig.updateProfile,
        data: updates,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final vendorData =
            responseData['vendor'] ?? responseData['data'] ?? responseData;
        final vendor = Vendor.fromJson(vendorData);

        // Update stored data
        final token = _storageService.getString(ApiConfig.tokenKey) ?? '';
        await saveVendorData(vendor, token);

        return vendor;
      } else {
        throw Exception(response.data['message'] ?? 'Update failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/storage/storage_service.dart';
import '../models/staff_model.dart';
import '../models/vendor_profile_model.dart';

class VendorAuthProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();
  final StorageService _storage = StorageService();

  bool _isLoading = false;
  String? _error;
  String? _pendingEmail;

  VendorProfileModel? _vendorProfile;
  StaffModel? _staffProfile;
  String? _token;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get pendingEmail => _pendingEmail;
  VendorProfileModel? get vendorProfile => _vendorProfile;
  StaffModel? get staffProfile => _staffProfile;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  StaffRole get role => _staffProfile?.role ?? StaffRole.branchStaff;

  Future<void> initSession() async {
    await _storage.init();
    _token = _storage.getAuthToken();
    if (_token != null && _token!.isNotEmpty) {
      await fetchProfiles();
    }
  }

  Future<bool> requestOtp(String email) async {
    _isLoading = true;
    _error = null;
    _pendingEmail = email.trim().toLowerCase();
    notifyListeners();

    try {
      await _client.post(
        ApiEndpoints.requestOtp,
        body: {
          'email': _pendingEmail,
          'purpose': 'LOGIN',
          'appType': 'VENDOR',
        },
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (_pendingEmail == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _client.post(
        ApiEndpoints.verifyOtp,
        body: {
          'email': _pendingEmail,
          'otp': otp.trim(),
          'appType': 'VENDOR',
        },
      );

      _token = res['token'] ?? res['accessToken'];
      if (_token != null) {
        await _storage.setAuthToken(_token!);
        await fetchProfiles();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchProfiles() async {
    try {
      final res = await _client.get(ApiEndpoints.vendorProfile);
      if (res is Map<String, dynamic>) {
        if (res['vendor'] != null) {
          _vendorProfile = VendorProfileModel.fromJson(res['vendor']);
        }
        if (res['staff'] != null) {
          _staffProfile = StaffModel.fromJson(res['staff']);
          if (_staffProfile != null) {
            await _storage.setUserRole(_staffProfile!.role.name);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[VendorAuthProvider] Fetch profiles error: $e');
    }
  }

  Future<bool> registerVendor({
    required String businessName,
    required String tradeLicenseNo,
    required String contactPhone,
    required String contactEmail,
    required String initialBranchName,
    required String branchAddress,
    required String thana,
    required String district,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _client.post(
        ApiEndpoints.vendorRegister,
        body: {
          'businessName': businessName,
          'tradeLicenseNo': tradeLicenseNo,
          'contactPhone': contactPhone,
          'contactEmail': contactEmail,
          'initialBranch': {
            'name': initialBranchName,
            'address': branchAddress,
            'thana': thana,
            'district': district,
          },
        },
      );

      _token = res['token'] ?? res['accessToken'];
      if (_token != null) {
        await _storage.setAuthToken(_token!);
        await fetchProfiles();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _vendorProfile = null;
    _staffProfile = null;
    _pendingEmail = null;
    await _storage.clearAuth();
    notifyListeners();
  }
}

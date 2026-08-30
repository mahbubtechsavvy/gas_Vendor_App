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
          'code': otp.trim(),
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
        } else if (res['id'] != null && res['status'] != null) {
          _vendorProfile = VendorProfileModel.fromJson(res);
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

    String formattedPhone = contactPhone.trim();
    if (formattedPhone.startsWith('01')) {
      formattedPhone = '+88$formattedPhone';
    } else if (formattedPhone.startsWith('8801')) {
      formattedPhone = '+$formattedPhone';
    } else if (!formattedPhone.startsWith('+8801') && formattedPhone.isNotEmpty) {
      formattedPhone = '+880$formattedPhone';
    }

    try {
      final res = await _client.post(
        ApiEndpoints.vendorRegister,
        body: {
          'legalName': businessName.trim(),
          'displayNameI18n': {
            'en': businessName.trim(),
            'bn': businessName.trim(),
          },
          'tradeLicenseNo': tradeLicenseNo.trim(),
          'contactPhone': formattedPhone,
          'contactEmail': contactEmail.trim().toLowerCase(),
          'primaryBranch': {
            'nameI18n': {
              'en': initialBranchName.trim().isNotEmpty ? initialBranchName.trim() : 'Main Branch',
              'bn': initialBranchName.trim().isNotEmpty ? initialBranchName.trim() : 'প্রধান শাখা',
            },
            'phone': formattedPhone,
            'addressLine': branchAddress.trim().isNotEmpty ? branchAddress.trim() : '$thana, $district',
            'area': thana.trim().isNotEmpty ? thana.trim() : district.trim(),
            'thana': thana.trim(),
            'district': district.trim().isNotEmpty ? district.trim() : 'Dhaka',
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

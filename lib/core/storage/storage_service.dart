import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> setAuthToken(String token) async {
    await _prefs?.setString(AppConfig.keyAuthToken, token);
  }

  String? getAuthToken() {
    return _prefs?.getString(AppConfig.keyAuthToken);
  }

  Future<void> setSelectedBranchId(String branchId) async {
    await _prefs?.setString(AppConfig.keySelectedBranchId, branchId);
  }

  String? getSelectedBranchId() {
    return _prefs?.getString(AppConfig.keySelectedBranchId);
  }

  Future<void> setUserRole(String role) async {
    await _prefs?.setString(AppConfig.keyUserRole, role);
  }

  String? getUserRole() {
    return _prefs?.getString(AppConfig.keyUserRole);
  }

  Future<void> setLocale(String locale) async {
    await _prefs?.setString(AppConfig.keyLocale, locale);
  }

  String getLocale() {
    return _prefs?.getString(AppConfig.keyLocale) ?? 'bn';
  }

  Future<void> setFcmToken(String token) async {
    await _prefs?.setString(AppConfig.keyFcmToken, token);
  }

  String? getFcmToken() {
    return _prefs?.getString(AppConfig.keyFcmToken);
  }

  Future<void> clearAuth() async {
    await _prefs?.remove(AppConfig.keyAuthToken);
    await _prefs?.remove(AppConfig.keySelectedBranchId);
    await _prefs?.remove(AppConfig.keyUserRole);
  }

  Future<void> clearToken() async {
    await clearAuth();
  }
}

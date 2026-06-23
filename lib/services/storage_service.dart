import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  SharedPreferences? _preferences;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  // Initialize SharedPreferences
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Save String
  Future<bool> saveString(String key, String value) async {
    return await _preferences?.setString(key, value) ?? false;
  }

  // Get String
  String? getString(String key) {
    return _preferences?.getString(key);
  }

  // Save Int
  Future<bool> saveInt(String key, int value) async {
    return await _preferences?.setInt(key, value) ?? false;
  }

  // Get Int
  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  // Save Bool
  Future<bool> saveBool(String key, bool value) async {
    return await _preferences?.setBool(key, value) ?? false;
  }

  // Get Bool
  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  // Save Object (as JSON)
  Future<bool> saveObject(String key, Map<String, dynamic> object) async {
    String jsonString = json.encode(object);
    return await saveString(key, jsonString);
  }

  // Get Object (from JSON)
  Map<String, dynamic>? getObject(String key) {
    String? jsonString = getString(key);
    if (jsonString == null) return null;
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  // Remove Key
  Future<bool> remove(String key) async {
    return await _preferences?.remove(key) ?? false;
  }

  // Clear All
  Future<bool> clearAll() async {
    return await _preferences?.clear() ?? false;
  }

  // Check if key exists
  bool containsKey(String key) {
    return _preferences?.containsKey(key) ?? false;
  }
}

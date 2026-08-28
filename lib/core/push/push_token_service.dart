import 'dart:io';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../storage/storage_service.dart';

class PushTokenService {
  static final PushTokenService _instance = PushTokenService._internal();
  factory PushTokenService() => _instance;
  PushTokenService._internal();

  final ApiClient _client = ApiClient();
  final StorageService _storage = StorageService();

  Future<void> registerDeviceToken(String fcmToken) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      await _storage.setFcmToken(fcmToken);
      await _client.post(
        ApiEndpoints.devices,
        body: {
          'token': fcmToken,
          'platform': 'ANDROID',
          'appType': 'VENDOR',
        },
      );
      debugPrint('[PushTokenService] Registered vendor device token');
    } catch (e) {
      debugPrint('[PushTokenService] Failed to register token: $e');
    }
  }

  Future<void> unregisterDeviceToken() async {
    final token = _storage.getFcmToken();
    if (token == null || token.isEmpty) return;

    try {
      await _client.delete('${ApiEndpoints.devices}?token=$token');
      debugPrint('[PushTokenService] Unregistered vendor device token');
    } catch (e) {
      debugPrint('[PushTokenService] Failed to unregister token: $e');
    }
  }
}

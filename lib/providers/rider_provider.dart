import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/rider_model.dart';

class RiderProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<RiderModel> _riders = [];
  bool _isLoading = false;
  String? _error;

  List<RiderModel> get riders => _riders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRiders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _client.get(ApiEndpoints.riders);
      if (res is List) {
        _riders = res.map((e) => RiderModel.fromJson(e)).toList();
      } else if (res is Map<String, dynamic> && res['riders'] is List) {
        _riders = (res['riders'] as List).map((e) => RiderModel.fromJson(e)).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addRider({
    required String fullName,
    required String phone,
    String? photoKey,
    String? nidNo,
    String? nidPhotoKey,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    String formattedPhone = phone.trim();
    if (formattedPhone.startsWith('01')) {
      formattedPhone = '+88$formattedPhone';
    } else if (formattedPhone.startsWith('8801')) {
      formattedPhone = '+$formattedPhone';
    }

    try {
      final body = <String, dynamic>{
        'name': fullName.trim(),
        'phone': formattedPhone,
      };
      if (photoKey != null && photoKey.trim().isNotEmpty) {
        body['photoKey'] = photoKey.trim();
      }
      if (nidNo != null && nidNo.trim().isNotEmpty) {
        body['nidNo'] = nidNo.trim();
      }
      if (nidPhotoKey != null && nidPhotoKey.trim().isNotEmpty) {
        body['nidPhotoKey'] = nidPhotoKey.trim();
      }

      await _client.post(
        ApiEndpoints.riders,
        body: body,
      );
      await fetchRiders();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignRiderToOrder({
    required String orderId,
    required String riderId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.post(
        ApiEndpoints.assignDelivery,
        body: {
          'orderId': orderId,
          'riderId': riderId,
        },
      );
      await fetchRiders();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

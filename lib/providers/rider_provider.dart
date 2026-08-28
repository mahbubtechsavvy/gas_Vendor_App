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
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.post(
        ApiEndpoints.riders,
        body: {
          'fullName': fullName.trim(),
          'phone': phone.trim(),
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

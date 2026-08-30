import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/rider_delivery_model.dart';

class RiderDeliveryProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  bool _isLoading = false;
  String? _error;

  List<RiderDeliveryTask> _assignedDeliveries = [];
  List<RiderDeliveryTask> _availableDeliveries = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<RiderDeliveryTask> get assignedDeliveries => _assignedDeliveries;
  List<RiderDeliveryTask> get availableDeliveries => _availableDeliveries;

  List<RiderDeliveryTask> get activeDeliveries =>
      _assignedDeliveries.where((d) => !d.isDelivered).toList();

  List<RiderDeliveryTask> get completedDeliveries =>
      _assignedDeliveries.where((d) => d.isDelivered).toList();

  Future<void> fetchAssignedDeliveries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _client.get(ApiEndpoints.riderAssignedDeliveries);
      if (res is List) {
        _assignedDeliveries =
            res.map((json) => RiderDeliveryTask.fromJson(json)).toList();
      } else {
        _assignedDeliveries = [];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchAvailableDeliveries() async {
    try {
      final res = await _client.get(ApiEndpoints.riderAvailableDeliveries);
      if (res is List) {
        _availableDeliveries =
            res.map((json) => RiderDeliveryTask.fromJson(json)).toList();
      } else {
        _availableDeliveries = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[RiderDeliveryProvider] Available deliveries error: $e');
    }
  }

  Future<bool> acceptDelivery(String deliveryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.post(ApiEndpoints.riderAcceptDelivery(deliveryId));
      await fetchAssignedDeliveries();
      await fetchAvailableDeliveries();
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

  Future<bool> markPickedUp(String deliveryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.post(ApiEndpoints.riderPickupDelivery(deliveryId));
      await fetchAssignedDeliveries();
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

  Future<bool> markDelivered(
    String deliveryId, {
    String? otp,
    String? proofKey,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.post(
        ApiEndpoints.riderCompleteDelivery(deliveryId),
        body: {
          if (otp != null && otp.isNotEmpty) 'deliveryOtp': otp,
          if (proofKey != null) 'proofKey': proofKey,
        },
      );
      await fetchAssignedDeliveries();
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
}

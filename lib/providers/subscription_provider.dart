import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/subscription_model.dart';

class SubscriptionProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<SubscriptionPlanModel> _plans = [];
  VendorSubscriptionModel? _currentSubscription;
  bool _isLoading = false;
  String? _error;

  List<SubscriptionPlanModel> get plans => _plans;
  VendorSubscriptionModel? get currentSubscription => _currentSubscription;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSubscriptionData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final plansRes = await _client.get(ApiEndpoints.subscriptionPlans);
      if (plansRes is List) {
        _plans = plansRes.map((e) => SubscriptionPlanModel.fromJson(e)).toList();
      } else if (plansRes is Map<String, dynamic> && plansRes['plans'] is List) {
        _plans = (plansRes['plans'] as List).map((e) => SubscriptionPlanModel.fromJson(e)).toList();
      }

      final subRes = await _client.get(ApiEndpoints.vendorSubscription);
      if (subRes is Map<String, dynamic>) {
        _currentSubscription = VendorSubscriptionModel.fromJson(subRes);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> submitManualPayment({
    required String vendorId,
    required String planCode,
    required String transactionId,
    required String paymentMethod,
    required int amountPaisa,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.post(
        ApiEndpoints.submitSubscriptionPayment(vendorId),
        body: {
          'planCode': planCode,
          'trxId': transactionId.trim(),
          'method': paymentMethod,
          'amountPaisa': amountPaisa,
        },
      );
      await fetchSubscriptionData();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

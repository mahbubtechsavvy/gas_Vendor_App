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

  Future<bool> subscribeAndSubmitPayment({
    required String planKey,
    required String method,
    required String senderPhone,
    required String transactionRef,
    required int amountPaisa,
    String? promoCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Choose/Create subscription plan
      final subRes = await _client.post(
        ApiEndpoints.choosePlan,
        body: {
          'planKey': planKey,
          if (promoCode != null && promoCode.trim().isNotEmpty) 'promoCode': promoCode.trim(),
        },
      );

      final subscriptionId = subRes is Map<String, dynamic>
          ? (subRes['id']?.toString() ?? '')
          : '';

      if (subscriptionId.isEmpty) {
        throw Exception('Failed to initialize subscription');
      }

      // 2. Submit payment proof
      await _client.post(
        ApiEndpoints.submitSubscriptionPayment(subscriptionId),
        body: {
          'method': method.toUpperCase(),
          'transactionRef': transactionRef.trim(),
          'amountPaisa': amountPaisa,
          'proofKey': 'Sender: ${senderPhone.trim()}',
        },
      );

      await fetchSubscriptionData();
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

  Future<bool> submitManualPayment({
    required String subscriptionId,
    required String planCode,
    required String transactionId,
    required String paymentMethod,
    required int amountPaisa,
    String senderPhone = '',
  }) async {
    return subscribeAndSubmitPayment(
      planKey: planCode,
      method: paymentMethod,
      senderPhone: senderPhone,
      transactionRef: transactionId,
      amountPaisa: amountPaisa,
    );
  }
}

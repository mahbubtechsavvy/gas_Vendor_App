import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/payout_method_model.dart';

class PayoutMethodProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<VendorPayoutMethodModel> _methods = [];
  bool _isLoading = false;
  String? _error;

  List<VendorPayoutMethodModel> get methods => _methods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<VendorPayoutMethodModel> get approvedMethods => _methods.where((m) => m.isApproved).toList();
  List<VendorPayoutMethodModel> get pendingMethods => _methods.where((m) => m.isPending).toList();

  Future<void> fetchPayoutMethods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _client.get(ApiEndpoints.vendorPayoutMethods);
      if (res is List) {
        _methods = res.map((m) => VendorPayoutMethodModel.fromJson(m as Map<String, dynamic>)).toList();
      } else {
        _methods = [];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addPayoutMethod({
    required String type, // BKASH, NAGAD, ROCKET, BANK
    required String accountType, // PERSONAL, AGENT, MERCHANT, SAVINGS, CURRENT
    required String accountNumber,
    String? accountName,
    String? bankName,
    String? branchName,
    String? routingNumber,
    bool isDefault = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = {
        'type': type,
        'accountType': accountType,
        'accountNumber': accountNumber.trim(),
        if (accountName != null && accountName.trim().isNotEmpty) 'accountName': accountName.trim(),
        if (bankName != null && bankName.trim().isNotEmpty) 'bankName': bankName.trim(),
        if (branchName != null && branchName.trim().isNotEmpty) 'branchName': branchName.trim(),
        if (routingNumber != null && routingNumber.trim().isNotEmpty) 'routingNumber': routingNumber.trim(),
        'isDefault': isDefault,
      };

      await _client.post(ApiEndpoints.vendorPayoutMethods, body: body);
      await fetchPayoutMethods();
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

  Future<bool> deletePayoutMethod(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _client.delete(ApiEndpoints.vendorPayoutMethod(id));
      await fetchPayoutMethods();
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
